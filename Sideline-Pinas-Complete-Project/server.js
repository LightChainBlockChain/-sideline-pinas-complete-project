const express = require('express');
const path = require('path');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS
app.use(cors());

// Serve static files from frontend directory
app.use(express.static(path.join(__dirname, 'frontend')));

// Serve contract artifacts
app.use('/contracts', express.static(path.join(__dirname, 'frontend/contracts')));

// Default route
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'frontend', 'index.html'));
});

// API endpoint to get contract addresses
app.get('/api/contracts', (req, res) => {
    res.json({
        VERI_TOKEN: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
        LIGHT_TOKEN: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
        NETWORK_ID: 1337,
        RPC_URL: "http://127.0.0.1:8545"
    });
});

app.listen(PORT, () => {
    console.log(`
🌟 Sideline Pinas Frontend Server Started!
🚀 Server running on: http://localhost:${PORT}
🦊 MetaMask Integration: Ready
📋 Contract Dashboard: Available
🔗 Make sure your Hardhat local network is running on port 8545
    `);
});
