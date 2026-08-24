require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const studentRoutes = require('./routes/students');
const attendanceRoutes = require('./routes/attendance');
const gradeRoutes = require('./routes/grades');
const feeRoutes = require('./routes/fees');
const classroomRoutes = require('./routes/classroom');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.use('/auth', authRoutes);
app.use('/students', studentRoutes);
app.use('/attendance', attendanceRoutes);
app.use('/grades', gradeRoutes);
app.use('/fees', feeRoutes);
app.use('/classroom', classroomRoutes);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Something went wrong on our end' });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
