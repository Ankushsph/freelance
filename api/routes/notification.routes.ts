import express, { type Response } from 'express';
import Notification from '../models/Notification.js';
import { verifyToken, type AuthRequest } from '../middleware/auth.js';

const router = express.Router();

// GET user notifications
router.get('/', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { limit = 20, skip = 0, unreadOnly = 'false' } = req.query;

    const query: any = { userId };
    if (unreadOnly === 'true') {
      query.read = false;
    }

    const notifications = await Notification.find(query)
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .skip(Number(skip));

    const unreadCount = await Notification.countDocuments({ userId, read: false });
    const total = await Notification.countDocuments(query);

    res.json({
      notifications,
      unreadCount,
      total,
      hasMore: total > Number(skip) + notifications.length,
    });
  } catch (error: any) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ message: error.message });
  }
});

// GET unread count
router.get('/unread-count', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const count = await Notification.countDocuments({ userId, read: false });
    
    res.json({ count });
  } catch (error: any) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({ message: error.message });
  }
});

// MARK notification as read
router.put('/:id/read', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const notification = await Notification.findOneAndUpdate(
      { _id: id, userId },
      { read: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.json({ message: 'Notification marked as read', notification });
  } catch (error: any) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ message: error.message });
  }
});

// MARK all notifications as read
router.put('/read-all', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;

    const result = await Notification.updateMany(
      { userId, read: false },
      { read: true }
    );

    res.json({
      message: 'All notifications marked as read',
      updated: result.modifiedCount,
    });
  } catch (error: any) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({ message: error.message });
  }
});

// DELETE notification
router.delete('/:id', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const notification = await Notification.findOneAndDelete({ _id: id, userId });

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.json({ message: 'Notification deleted' });
  } catch (error: any) {
    console.error('Error deleting notification:', error);
    res.status(500).json({ message: error.message });
  }
});

// DELETE all read notifications
router.delete('/clear-read', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;

    const result = await Notification.deleteMany({ userId, read: true });

    res.json({
      message: 'Read notifications cleared',
      deleted: result.deletedCount,
    });
  } catch (error: any) {
    console.error('Error clearing notifications:', error);
    res.status(500).json({ message: error.message });
  }
});

export default router;
