const mongoose = require('mongoose');

const adminSchema = new mongoose.Schema({
  email: String,
  password: String,
  image: String,
  name: String
}, {
  collection: "Admin"
});


// module.exports = mongoose.model('Admin', adminSchema);

module.exports = mongoose.model('Admin', adminSchema);
