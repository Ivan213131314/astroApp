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
        'today': 'на сегодня',
        'tomorrow': 'на завтра',
        'this_week': 'на эту неделю'
    }[period];

    return `Ты профессиональный астролог. Создай детальный гороскоп для знака зодиака ${zodiacSign} ${periodText}.

CRITICAL: You MUST return ONLY a single valid JSON object.

Strict rules:
- No markdown code blocks (no \`\`\`json or \`\`\`)
- No additional tokens (no <|im_end|>, <s>, </s>, [/INST], etc.)
- No explanations, comments, or extra text
- Output ONLY the JSON object
- JSON must be complete, valid, and properly closed
- All text fields must be in Russian

Required JSON structure:
{
  "overall": {
    "score": <число от 1 до 100>,
    "text": "<краткое описание общего прогноза, 2-3 предложения>",
    "deepText": "<детальный анализ, 4-5 предложений с конкретными советами>"
  },
  "love": {
    "score": <число от 1 до 100>,
    "text": "<краткое описание любовного прогноза, 2-3 предложения>",
    "deepText": "<детальный анализ личной жизни, 4-5 предложений>"
  },
  "business": {
    "score": <число от 1 до 100>,
    "text": "<краткое описание карьерного прогноза, 2-3 предложения>",
    "deepText": "<детальный анализ карьеры и финансов, 4-5 предложений>"
  },
  "health": {
    "score": <число от 1 до 100>,
    "text": "<краткое описание прогноза здоровья, 2-3 предложения>",
    "deepText": "<детальный анализ здоровья и самочувствия, 4-5 предложений>"
  }
}

Rules:
- Все тексты НА РУССКОМ ЯЗЫКЕ
- Scores должны быть целыми числами от 1 до 100
- Тексты должны быть уникальными и конкретными
- Используй астрологическую терминологию
- JSON должен быть полным и валидным
- Закрой все скобки правильно

If you cannot generate a full response, return this fallback EXACTLY:
{
  "overall": {"score": 50, "text": "Временно недоступен", "deepText": "Временно недоступен"},
  "love": {"score": 50, "text": "Временно недоступен", "deepText": "Временно недоступен"},
  "business": {"score": 50, "text": "Временно недоступен", "deepText": "Временно недоступен"},
  "health": {"score": 50, "text": "Временно недоступен", "deepText": "Временно недоступен"}
}

START YOUR RESPONSE WITH { AND END WITH }`;
}

/**
 * Call OpenRouter AI API to generate horoscope
 */
async function generateHoroscopeWithAI(zodiacSign, period) {
    try {
        const prompt = generatePrompt(zodiacSign, period);

        console.log(`Generating horoscope for ${zodiacSign} (${period})...`);

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

        const horoscopeData = JSON.parse(jsonText);

        console.log(`✓ Generated horoscope for ${zodiacSign} (${period})`);

        return horoscopeData;
    } catch (error) {
        console.error(`Error generating horoscope for ${zodiacSign} (${period}):`, error.message);

        // Return fallback data if AI fails
        return {
            overall: {
                score: 75,
                text: 'Сегодня звезды благоприятствуют новым начинаниям. Будьте открыты к возможностям.',
                deepText: 'Планетарные аспекты указывают на период позитивных изменений. Используйте это время для самосовершенствования и развития. Доверяйте своей интуиции.'
            },
            love: {
                score: 80,
                text: 'В отношениях ожидается гармония и понимание.',
                deepText: 'Венера находится в благоприятном положении, что создает прекрасные условия для романтики и укрепления связей.'
            },
            business: {
                score: 70,
                text: 'Профессиональные дела требуют внимания и концентрации.',
                deepText: 'Марс придает энергии для достижения карьерных целей. Это хорошее время для важных решений.'
            },
            health: {
                score: 75,
                text: 'Общее самочувствие стабильное, следите за режимом дня.',
                deepText: 'Луна влияет на эмоциональное состояние. Уделите внимание отдыху и восстановлению сил.'
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
