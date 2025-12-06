const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

// Initialize Firebase Admin
admin.initializeApp();

// OpenRouter API configuration
const OPENROUTER_API_KEY = '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';
const OPENROUTER_BASE_URL = 'https://openrouter.ai/api/v1/chat/completions';
const AI_MODEL = 'mistralai/mistral-7b-instruct:free';

// Zodiac signs in English (for Firestore keys) and Russian (for prompts)
const ZODIAC_SIGNS = [
    { en: 'aries', ru: 'Овен' },
    { en: 'taurus', ru: 'Телец' },
    { en: 'gemini', ru: 'Близнецы' },
    { en: 'cancer', ru: 'Рак' },
    { en: 'leo', ru: 'Лев' },
    { en: 'virgo', ru: 'Дева' },
    { en: 'libra', ru: 'Весы' },
    { en: 'scorpio', ru: 'Скорпион' },
    { en: 'sagittarius', ru: 'Стрелец' },
    { en: 'capricorn', ru: 'Козерог' },
    { en: 'aquarius', ru: 'Водолей' },
    { en: 'pisces', ru: 'Рыбы' }
];

const PERIODS = ['today', 'tomorrow', 'this_week'];

/**
 * Generate AI prompt for horoscope
 */
function generatePrompt(zodiacSign, period) {
    const periodText = {
        'today': 'for today',
        'tomorrow': 'for tomorrow',
        'this_week': 'for this week'
    }[period];

    return `You are a professional astrologer. Create a detailed horoscope for the zodiac sign ${zodiacSign} ${periodText}.

CRITICAL: You MUST return ONLY a single valid JSON object.

Strict rules:
- No markdown code blocks (no \`\`\`json or \`\`\`)
- No additional tokens (no <|im_end|>, <s>, </s>, [/INST], etc.)
- No explanations, comments, or extra text
- Output ONLY the JSON object
- JSON must be complete, valid, and properly closed
- All text fields must be in ENGLISH language

Required JSON structure:
{
  "overall": {
    "score": <number from 1 to 100>,
    "text": "<brief description of overall forecast, 2-3 sentences>",
    "deepText": "<detailed analysis, 4-5 sentences with specific advice>"
  },
  "love": {
    "score": <number from 1 to 100>,
    "text": "<brief description of love forecast, 2-3 sentences>",
    "deepText": "<detailed analysis of personal life, 4-5 sentences>"
  },
  "business": {
    "score": <number from 1 to 100>,
    "text": "<brief description of career forecast, 2-3 sentences>",
    "deepText": "<detailed analysis of career and finances, 4-5 sentences>"
  },
  "health": {
    "score": <number from 1 to 100>,
    "text": "<brief description of health forecast, 2-3 sentences>",
    "deepText": "<detailed analysis of health and wellbeing, 4-5 sentences>"
  }
}

Rules:
- All texts must be in ENGLISH language
- Scores must be integers from 1 to 100
- Texts must be unique and specific
- Use astrological terminology
- JSON must be complete and valid
- Close all brackets properly

If you cannot generate a full response, return this fallback EXACTLY:
{
  "overall": {"score": 50, "text": "Temporarily unavailable", "deepText": "Temporarily unavailable"},
  "love": {"score": 50, "text": "Temporarily unavailable", "deepText": "Temporarily unavailable"},
  "business": {"score": 50, "text": "Temporarily unavailable", "deepText": "Temporarily unavailable"},
  "health": {"score": 50, "text": "Temporarily unavailable", "deepText": "Temporarily unavailable"}
}

START YOUR RESPONSE WITH { AND END WITH }`;
}

/**
 * Call OpenRouter AI API to generate horoscope with retry logic
 * Retries up to MAX_RETRIES times if JSON parsing fails
 */
async function generateHoroscopeWithAI(zodiacSign, period, retryCount = 0) {
    const MAX_RETRIES = 3;

    try {
        const prompt = generatePrompt(zodiacSign, period);

        console.log(`Generating horoscope for ${zodiacSign} (${period})... ${retryCount > 0 ? `(Attempt ${retryCount + 1}/${MAX_RETRIES})` : ''}`);

        const response = await axios.post(
            OPENROUTER_BASE_URL,
            {
                model: AI_MODEL,
                messages: [
                    {
                        role: 'user',
                        content: prompt
                    }
                ],
                temperature: 0.7,
                max_tokens: 2000  // Increased to ensure complete JSON
            },
            {
                headers: {
                    'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
                    'Content-Type': 'application/json',
                    'HTTP-Referer': 'https://astrocircle.app',
                    'X-Title': 'Astro Circle'
                }
            }
        );

        const aiResponse = response.data.choices[0].message.content;

        console.log(`Raw AI response: ${aiResponse.substring(0, 200)}...`);

        // Aggressive JSON extraction from AI response
        let jsonText = aiResponse.trim();

        // Remove Mistral special tokens like <s>, </s>, [/INST], etc.
        jsonText = jsonText.replace(/<\/?s>/g, '');
        jsonText = jsonText.replace(/\[INST\].*?\[\/INST\]/gs, '');
        jsonText = jsonText.replace(/\[\/INST\]/g, '');

        // Remove markdown code blocks
        jsonText = jsonText.replace(/```json\n?/g, '').replace(/```js\n?/g, '').replace(/```\n?/g, '');

        // Find JSON object boundaries
        const startIdx = jsonText.indexOf('{');
        const endIdx = jsonText.lastIndexOf('}');

        if (startIdx !== -1 && endIdx !== -1) {
            jsonText = jsonText.substring(startIdx, endIdx + 1);
        }

        jsonText = jsonText.trim();

        console.log(`Cleaned JSON: ${jsonText.substring(0, 200)}...`);

        // Try to parse JSON
        const horoscopeData = JSON.parse(jsonText);

        // Validate that all required fields exist
        if (!horoscopeData.overall || !horoscopeData.love || !horoscopeData.business || !horoscopeData.health) {
            throw new Error('Missing required horoscope categories');
        }

        console.log(`✓ Successfully generated horoscope for ${zodiacSign} (${period})`);

        return horoscopeData;
    } catch (error) {
        console.error(`Error generating horoscope for ${zodiacSign} (${period}):`, error.message);

        // Retry if we haven't exceeded max retries
        if (retryCount < MAX_RETRIES - 1) {
            console.log(`Retrying... (${retryCount + 1}/${MAX_RETRIES - 1})`);

            // Wait a bit before retrying (exponential backoff: 1s, 2s, 4s)
            const waitTime = Math.pow(2, retryCount) * 1000;
            await new Promise(resolve => setTimeout(resolve, waitTime));

            // Recursive retry
            return generateHoroscopeWithAI(zodiacSign, period, retryCount + 1);
        }

        // All retries failed, return fallback data
        console.error(`All ${MAX_RETRIES} attempts failed for ${zodiacSign} (${period}), using fallback data`);
        return {
            overall: {
                score: 75,
                text: 'The stars favor new beginnings today. Be open to opportunities.',
                deepText: 'Planetary aspects indicate a period of positive change. Use this time for self-improvement and development. Trust your intuition and embrace the cosmic energies surrounding you.'
            },
            love: {
                score: 80,
                text: 'Harmony and understanding are expected in relationships.',
                deepText: 'Venus is in a favorable position, creating excellent conditions for romance and strengthening bonds. This is an ideal time to express your feelings and deepen emotional connections with loved ones.'
            },
            business: {
                score: 70,
                text: 'Professional matters require attention and concentration.',
                deepText: 'Mars provides energy to achieve career goals. This is a good time for important decisions. Focus on strategic planning and building professional relationships that will serve you long-term.'
            },
            health: {
                score: 75,
                text: 'Overall well-being is stable, monitor your daily routine.',
                deepText: 'The Moon influences your emotional state. Pay attention to rest and recovery. Balance physical activity with relaxation to maintain optimal health and energy levels.'
            }
        };
    }
}

/**
 * Save horoscope to Firestore
 */
async function saveHoroscope(zodiacSign, date, period, data) {
    const db = admin.firestore();
    const documentId = `${zodiacSign}_${date}_${period}`;

    await db.collection('horoscopes').doc(documentId).set({
        zodiacSign: zodiacSign,
        date: date,
        period: period,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
        data: data
    });

    console.log(`✓ Saved to Firestore: ${documentId}`);
}

/**
 * Main Cloud Function - scheduled to run daily at 00:00 UTC
 * Generates horoscopes for all zodiac signs and all periods
 */
exports.generateDailyHoroscopes = functions
    .runWith({
        timeoutSeconds: 540, // 9 minutes - max allowed for Cloud Functions
        memory: '512MB'
    })
    .region('us-central1')
    .pubsub
    .schedule('0 0 * * *') // Every day at 00:00 UTC
    .timeZone('UTC')
    .onRun(async (context) => {
        console.log('========================================');
        console.log('Starting daily horoscope generation...');
        console.log(`Timestamp: ${new Date().toISOString()}`);
        console.log('========================================');

        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        // Format dates as YYYY-MM-DD
        const todayStr = today.toISOString().split('T')[0];
        const tomorrowStr = tomorrow.toISOString().split('T')[0];

        let successCount = 0;
        let errorCount = 0;

        // Generate horoscopes for all zodiac signs
        for (const zodiac of ZODIAC_SIGNS) {
            for (const period of PERIODS) {
                try {
                    // Determine the date for this horoscope
                    let dateStr = todayStr;
                    if (period === 'tomorrow') {
                        dateStr = tomorrowStr;
                    } else if (period === 'this_week') {
                        dateStr = todayStr; // Week starts today
                    }

                    // Generate horoscope data with AI
                    const horoscopeData = await generateHoroscopeWithAI(zodiac.ru, period);

                    // Save to Firestore
                    await saveHoroscope(zodiac.en, dateStr, period, horoscopeData);

                    successCount++;

                    // Add small delay to avoid rate limiting
                    await new Promise(resolve => setTimeout(resolve, 500));
                } catch (error) {
                    console.error(`Error processing ${zodiac.en} (${period}):`, error.message);
                    errorCount++;
                }
            }
        }

        console.log('========================================');
        console.log(`Horoscope generation completed!`);
        console.log(`✓ Success: ${successCount}`);
        console.log(`✗ Errors: ${errorCount}`);
        console.log('========================================');

        return null;
    });

/**
 * Manual trigger for testing (HTTP function)
 * Call this to manually generate horoscopes without waiting for the schedule
 */
exports.generateHoroscopesManual = functions
    .runWith({
        timeoutSeconds: 540, // 9 minutes - max allowed for Cloud Functions
        memory: '512MB'
    })
    .region('us-central1')
    .https
    .onRequest(async (req, res) => {
        console.log('Manual horoscope generation triggered');

        try {
            // Call the scheduled function logic
            await exports.generateDailyHoroscopes.run({});

            res.status(200).send({
                success: true,
                message: 'Horoscopes generated successfully!'
            });
        } catch (error) {
            console.error('Error in manual generation:', error);
            res.status(500).send({
                success: false,
                error: error.message
            });
        }
    });
