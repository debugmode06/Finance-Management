const cron = require('node-cron');
const { runReminderScans } = require('../services/reminder.service');

/**
 * Schedule the reminder scan cron job.
 * Default: runs at 8:00 AM every day.
 * Override via REMINDER_CRON_SCHEDULE env var.
 */
const startReminderCron = () => {
  const schedule = process.env.REMINDER_CRON_SCHEDULE || '0 8 * * *';

  if (!cron.validate(schedule)) {
    console.error(`[Cron] Invalid cron schedule: "${schedule}". Reminder cron not started.`);
    return;
  }

  cron.schedule(schedule, async () => {
    console.log(`[Cron] Reminder job triggered at ${new Date().toISOString()}`);
    await runReminderScans();
  });

  console.log(`✅ Reminder cron scheduled: "${schedule}"`);
};

module.exports = { startReminderCron };
