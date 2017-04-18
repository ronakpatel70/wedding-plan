var TestResponses = {
  empty: {
    status: 200,
    responseText: ''
  },
  error: {
    status: 500,
    responseText: ''
  },
  search: {
    success: {
      status: 200,
      responseText: '{"users": [{"first_name": "Dylan", "last_name": "Waits", "url": "/admin/users/1"}, {"first_name": "Megan", "last_name": "Waits", "url": "/admin/users/2"}]}'
    }
  }
};
