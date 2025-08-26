import { useNotificationContext } from '../contexts/NotificationContext';

const useNotification = () => {
  return useNotificationContext();
};

export default useNotification;
