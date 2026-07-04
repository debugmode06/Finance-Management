const { Server } = require('socket.io');

let io;
const userSocketMap = new Map(); // userId -> Set of socketIds

const initSocket = (httpServer) => {
  io = new Server(httpServer, {
    cors: {
      origin: process.env.CLIENT_URL || '*',
      methods: ['GET', 'POST'],
      credentials: true,
    },
    pingTimeout: 60000,
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Socket connected: ${socket.id}`);

    // Client sends their userId to register
    socket.on('register', (userId) => {
      if (!userId) return;
      if (!userSocketMap.has(userId)) {
        userSocketMap.set(userId, new Set());
      }
      userSocketMap.get(userId).add(socket.id);
      socket.join(`user:${userId}`);
      console.log(`📡 User ${userId} registered socket ${socket.id}`);
    });

    socket.on('disconnect', () => {
      // Clean up the userSocketMap
      for (const [userId, socketIds] of userSocketMap.entries()) {
        socketIds.delete(socket.id);
        if (socketIds.size === 0) {
          userSocketMap.delete(userId);
        }
      }
      console.log(`🔌 Socket disconnected: ${socket.id}`);
    });
  });

  return io;
};

/**
 * Emit a notification to a specific user
 * @param {string} userId - target user's MongoDB ObjectId as string
 * @param {string} event - event name
 * @param {object} payload - data to send
 */
const emitToUser = (userId, event, payload) => {
  if (!io) return;
  io.to(`user:${userId}`).emit(event, payload);
};

const getIO = () => {
  if (!io) throw new Error('Socket.IO not initialized');
  return io;
};

module.exports = { initSocket, emitToUser, getIO };
