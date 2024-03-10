const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema({
    name: String,
    email: String,
    password: String,
    phoneNumber: String,
    city: String,
    locationMap: {
        type: [Number], 
        index: '2dsphere',
    },
    city: String,
    Rating: {
        type: Number, 
        default: 0, 
    },
    StartTime: String,
    EndTime: String,
    category: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Categories'
    },
    WorkingDays: [
        {
            type: String, 
            enum: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        }
    ],
    ProfileImg: String,
    token: String,
    appointmentTime: {
        type: Number, 
        default: 30, 
    }
}, { collection: 'Doctors' });

const Doctor = mongoose.model('Doctors', doctorSchema);

module.exports = Doctor;
