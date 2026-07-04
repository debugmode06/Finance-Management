require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const User = require('../models/User');
const Proposal = require('../models/Proposal');
const ProposalHistory = require('../models/ProposalHistory');
const { ROLES, DEPARTMENTS, PROPOSAL_STATUSES, PROPOSAL_PRIORITIES } = require('../utils/constants');

const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/csea_finance';

const seed = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing data
    await Promise.all([
      User.deleteMany({}),
      Proposal.deleteMany({}),
      ProposalHistory.deleteMany({}),
    ]);
    console.log('🧹 Cleared existing data');

    // ─── Create Finance Director ───────────────────────────────────────────
    const fdPassword = await User.hashPassword('Admin@1234');
    const financeDirector = await User.create({
      name: 'Finance Director',
      email: 'admin@csea.edu',
      phone: '+60123456789',
      role: ROLES.FINANCE_DIRECTOR,
      department: null,
      passwordHash: fdPassword,
      isActive: true,
    });
    console.log(`✅ Finance Director created: admin@csea.edu / Admin@1234`);

    // ─── Create Directors ──────────────────────────────────────────────────
    const directorData = [
      { name: 'Ahmad Razif', email: 'ahmad@csea.edu', department: DEPARTMENTS.TECHNICAL_ACTIVITIES },
      { name: 'Nurul Ain', email: 'nurul@csea.edu', department: DEPARTMENTS.MEDIA_COMMUNICATION },
      { name: 'Hafiz Rahman', email: 'hafiz@csea.edu', department: DEPARTMENTS.EVENTS_OUTREACH },
      { name: 'Siti Zara', email: 'siti@csea.edu', department: DEPARTMENTS.PROFESSIONAL_DEVELOPMENT },
      { name: 'Farid Ismail', email: 'farid@csea.edu', department: DEPARTMENTS.ENTREPRENEURSHIP },
      { name: 'Amirah Yusof', email: 'amirah@csea.edu', department: DEPARTMENTS.CLUB },
    ];

    const dirPassword = await User.hashPassword('Director@1234');
    const directors = await User.insertMany(
      directorData.map((d) => ({
        ...d,
        role: ROLES.DIRECTOR,
        passwordHash: dirPassword,
        isActive: true,
      }))
    );
    console.log(`✅ ${directors.length} Directors created (password: Director@1234)`);

    // ─── Create Sample Proposals ───────────────────────────────────────────
    const proposalSamples = [
      {
        title: 'Annual Tech Symposium 2025',
        department: DEPARTMENTS.TECHNICAL_ACTIVITIES,
        eventName: 'Tech Symposium 2025',
        purpose: 'Foster technical knowledge sharing among students',
        description: 'An annual symposium featuring keynote speakers from the tech industry, workshops, hackathons, and networking sessions. This event aims to bridge the gap between academia and industry by providing students with real-world insights.',
        requestedBudget: 5000,
        priority: PROPOSAL_PRIORITIES.HIGH,
        requiredDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        status: PROPOSAL_STATUSES.SUBMITTED,
        submittedAt: new Date(),
        createdBy: directors[0]._id,
      },
      {
        title: 'Social Media Campaign Q3',
        department: DEPARTMENTS.MEDIA_COMMUNICATION,
        eventName: 'CSEA Digital Outreach',
        purpose: 'Increase CSEA visibility on social media platforms',
        description: 'A comprehensive social media campaign targeting Instagram, LinkedIn, and TikTok to grow CSEA membership and engagement. The campaign includes content creation, paid promotions, and influencer collaborations.',
        requestedBudget: 1500,
        priority: PROPOSAL_PRIORITIES.MEDIUM,
        requiredDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
        status: PROPOSAL_STATUSES.APPROVED,
        approvedBudget: 1200,
        submittedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        approvedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        reviewedBy: financeDirector._id,
        reviewedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        createdBy: directors[1]._id,
      },
      {
        title: 'Industry Visit to TechCorp HQ',
        department: DEPARTMENTS.EVENTS_OUTREACH,
        eventName: 'TechCorp Industry Visit',
        purpose: 'Expose students to real-world engineering practices',
        description: 'A guided visit to TechCorp headquarters for 50 students. The visit includes a company tour, presentations by engineers, Q&A sessions, and lunch. This provides invaluable exposure to professional engineering environments.',
        requestedBudget: 2000,
        priority: PROPOSAL_PRIORITIES.HIGH,
        requiredDate: new Date(Date.now() + 21 * 24 * 60 * 60 * 1000),
        status: PROPOSAL_STATUSES.REJECTED,
        rejectionReason: 'Budget exceeds current quarter allocation. Please reduce the budget to RM1500 or seek additional sponsorship and resubmit.',
        submittedAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
        reviewedBy: financeDirector._id,
        reviewedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
        createdBy: directors[2]._id,
      },
      {
        title: 'Professional Resume Workshop',
        department: DEPARTMENTS.PROFESSIONAL_DEVELOPMENT,
        eventName: 'Resume & Interview Skills Workshop',
        purpose: 'Prepare final year students for job applications',
        description: 'A two-day intensive workshop covering resume writing, LinkedIn optimization, mock interviews, and career planning. Industry professionals will be invited as guest speakers and mock interviewers.',
        requestedBudget: 800,
        priority: PROPOSAL_PRIORITIES.MEDIUM,
        requiredDate: new Date(Date.now() + 45 * 24 * 60 * 60 * 1000),
        status: PROPOSAL_STATUSES.DRAFT,
        createdBy: directors[3]._id,
      },
      {
        title: 'Startup Pitch Competition',
        department: DEPARTMENTS.ENTREPRENEURSHIP,
        eventName: 'CSEA Startup Pitch 2025',
        purpose: 'Cultivate entrepreneurship mindset among engineering students',
        description: 'A competition where student teams pitch their startup ideas to a panel of investors and entrepreneurs. The event includes mentoring sessions, a pitch showcase, and cash prizes for winning teams.',
        requestedBudget: 3500,
        priority: PROPOSAL_PRIORITIES.URGENT,
        requiredDate: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000),
        status: PROPOSAL_STATUSES.WAITING_FOR_BILLS,
        approvedBudget: 3000,
        submittedAt: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000),
        approvedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        reviewedBy: financeDirector._id,
        reviewedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        createdBy: directors[4]._id,
      },
      {
        title: 'Annual Club Dinner 2025',
        department: DEPARTMENTS.CLUB,
        eventName: 'CSEA Annual Dinner',
        purpose: 'Celebrate the academic year achievements and foster community',
        description: 'The annual club dinner is a formal event celebrating the achievements of CSEA members throughout the academic year. The event features award presentations, cultural performances, networking, and a gala dinner.',
        requestedBudget: 6000,
        priority: PROPOSAL_PRIORITIES.HIGH,
        requiredDate: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000),
        status: PROPOSAL_STATUSES.COMPLETED,
        approvedBudget: 5500,
        actualExpense: 5230,
        submittedAt: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000),
        approvedAt: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000),
        completedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        reviewedBy: financeDirector._id,
        reviewedAt: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000),
        createdBy: directors[5]._id,
      },
    ];

    const proposals = await Proposal.insertMany(proposalSamples);
    console.log(`✅ ${proposals.length} Sample proposals created`);

    // ─── Create history entries ────────────────────────────────────────────
    const historyEntries = proposals.map((p) => ({
      proposalId: p._id,
      status: p.status,
      changedBy: p.createdBy,
      note: `Seeded with status: ${p.status}`,
      timestamp: new Date(),
    }));
    await ProposalHistory.insertMany(historyEntries);
    console.log('✅ Proposal history seeded');

    console.log('\n═══════════════════════════════════════════');
    console.log('   SEED COMPLETE');
    console.log('═══════════════════════════════════════════');
    console.log('Finance Director:');
    console.log('  Email:    admin@csea.edu');
    console.log('  Password: Admin@1234');
    console.log('\nDirectors (all):');
    directorData.forEach((d) => {
      console.log(`  ${d.email.padEnd(25)} — ${d.department}`);
    });
    console.log('  Password: Director@1234');
    console.log('═══════════════════════════════════════════\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  }
};

seed();
