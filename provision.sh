#!/bin/bash

# Update system and install dependencies
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install essential packages
echo "Installing system dependencies..."
apt-get install -y \
    python3-pip \
    python3-venv \
    git \
    wget \
    curl \
    build-essential

# Install NVIDIA drivers if VirtualBox provides virtual GPU
apt-get install -y \
    ocl-icd-libopencl1

# Create dedicated user for DeepSeek Coder
if ! id "deepseek" &>/dev/null; then
    useradd -m -s /bin/bash deepseek
    usermod -aG sudo deepseek
    # Set password for the user (optional)
    echo "deepseek:deepseek123" | chpasswd
fi

# Switch to deepseek user and setup environment
sudo -u deepseek bash << 'EOF'
cd /home/deepseek

# Create Python virtual environment
python3 -m venv deepseek-env
source deepseek-env/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install transformers accelerate bitsandbytes fastapi uvicorn

# Clone DeepSeek Coder repository
if [ ! -d "DeepSeek-Coder" ]; then
    git clone https://github.com/deepseek-ai/DeepSeek-Coder.git
fi

cd DeepSeek-Coder

# Create model directory
mkdir -p models
cd models

echo "Downloading DeepSeek Coder model..."
# For smaller model (1.3B) - suitable for most systems
if [ ! -f "pytorch_model.bin" ]; then
    wget -q https://huggingface.co/deepseek-ai/deepseek-coder-1.3b-instruct/resolve/main/pytorch_model.bin
fi

cd ..

# Create startup script
cat > start_deepseek.sh << 'SCRIPT'
#!/bin/bash
cd /home/deepseek/DeepSeek-Coder
source /home/deepseek/deepseek-env/bin/activate

# Start the API server
python -m uvicorn api:app --host 0.0.0.0 --port 8000 --reload
SCRIPT

chmod +x start_deepseek.sh

EOF

# Create systemd service as root
cat > /etc/systemd/system/deepseek-coder.service << 'EOL'
[Unit]
Description=DeepSeek Coder API Service
After=network.target

[Service]
Type=simple
User=deepseek
WorkingDirectory=/home/deepseek/DeepSeek-Coder
Environment=PATH=/home/deepseek/deepseek-env/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/bin/bash /home/deepseek/DeepSeek-Coder/start_deepseek.sh
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL

# Fix permissions
chown deepseek:deepseek /home/deepseek/DeepSeek-Coder/start_deepseek.sh
chmod 644 /etc/systemd/system/deepseek-coder.service

# Reload systemd and enable service (but don't start it yet)
systemctl daemon-reload
systemctl enable deepseek-coder.service

echo "Setup complete! DeepSeek Coder service has been configured."
echo "To start the service, run: systemctl start deepseek-coder"
echo "To check status: systemctl status deepseek-coder"
echo "To view logs: journalctl -u deepseek-coder -f"