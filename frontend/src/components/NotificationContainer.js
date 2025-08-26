import React from 'react';
import { useNotificationContext } from '../contexts/NotificationContext';
import Notification from './Notification';

const NotificationContainer = () => {
  const { notifications, removeNotification } = useNotificationContext();

  return (
    <>
      {notifications.map((notification) => (
        <Notification
          key={notification.id}
          {...notification}
          onClose={() => removeNotification(notification.id)}
        />
      ))}
    </>
  );
};

export default NotificationContainer;
