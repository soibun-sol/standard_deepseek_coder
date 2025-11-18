# DeepSeek Coder Local Deployment

A complete local deployment of DeepSeek Coder AI model using VirtualBox, Vagrant, and FastAPI. This project allows you to run your own code generation AI model on a Virtual Private Server (VPS) or local machine.

## 📋 Overview

This project provides:
- **Local AI Code Generation**: Run DeepSeek Coder 1.3B model locally
- **REST API**: Easy-to-use HTTP endpoints for code generation
- **Automated Deployment**: One-command setup using Vagrant and VirtualBox
- **Production Ready**: Systemd service for reliable long-term operation

## 🚀 Quick Start

### Prerequisites

- **VirtualBox** (6.1 or newer)
- **Vagrant** (2.2.19 or newer)
- **8GB+ RAM** on host system (12GB allocated to VM)
- **20GB+ free disk space**
- **Ubuntu 22.04 LTS** (automatically downloaded)

### Installation

1. **Clone or download this project** to your local machine

2. **Start the deployment**:
   ```bash
   vagrant up
   ```

3. **Wait for provisioning** (20-30 minutes):
   - Downloads Ubuntu 22.04
   - Installs system dependencies
   - Downloads DeepSeek Coder 1.3B model
   - Configures the API service

4. **Access the API**:
   The service will be available at:
   - **VM Internal**: `http://192.168.56.20:8000`
   - **Host Machine**: `http://localhost:8000`

## 🛠 API Usage

### Health Check
```bash
curl http://localhost:8000/health
```
Response:
```json
{"status":"healthy","model_loaded":true}
```

### Code Generation
```bash
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Write a Python function to calculate fibonacci numbers",
    "max_length": 512,
    "temperature": 0.7,
    "top_p": 0.95
  }'
```

### Example Response
```json
{
  "generated_code": "def fibonacci(n):\n    if n <= 1:\n        return n\n    else:\n        return fibonacci(n-1) + fibonacci(n-2)",
  "status": "success"
}
```

## 📁 Project Structure

```
.
├── Vagrantfile          # VM configuration
├── provision.sh         # Automated setup script
├── api.py              # FastAPI application
└── README.md           # This file
```

## ⚙️ Configuration

### VM Resources (Customizable in Vagrantfile)
- **RAM**: 12GB (minimum for good performance)
- **CPUs**: 4 cores
- **Storage**: Dynamic allocation up to 25GB
- **Network**: Private network (192.168.56.20)

### Model Parameters
- **Model**: `deepseek-ai/deepseek-coder-1.3b-instruct`
- **Max Length**: 512 tokens (adjustable)
- **Temperature**: 0.7 (creativity control)
- **Top-p**: 0.95 (nucleus sampling)

## 🎯 Use Cases

### Ideal For:
- **Local Development**: Code completion without cloud dependencies
- **Learning AI**: Understanding transformer models locally
- **Prototyping**: Testing AI features before cloud deployment
- **Privacy-Sensitive Projects**: Code generation without external APIs
- **Educational Purposes**: Teaching AI and machine learning concepts

### Capabilities:
- **Code Completion**: Finish partial code snippets
- **Function Generation**: Create functions from descriptions
- **Bug Fixing**: Suggest fixes for code issues
- **Documentation**: Generate code comments and documentation
- **Language Translation**: Convert code between programming languages

## 🛠 Management Commands

### Service Management
```bash
# Start the service
vagrant ssh -c "sudo systemctl start deepseek-coder"

# Stop the service
vagrant ssh -c "sudo systemctl stop deepseek-coder"

# Check status
vagrant ssh -c "sudo systemctl status deepseek-coder"

# View logs
vagrant ssh -c "sudo journalctl -u deepseek-coder -f"
```

### VM Management
```bash
# SSH into VM
vagrant ssh

# Suspend VM
vagrant suspend

# Halt VM
vagrant halt

# Destroy VM (deletes everything)
vagrant destroy
```

## 🔧 Troubleshooting

### Common Issues

1. **Out of Memory**:
   - Reduce VM memory in Vagrantfile (`vb.memory = 8192`)
   - Close other applications on host

2. **Port Conflicts**:
   - Change host port in Vagrantfile (`host: 8001`)

3. **Slow Generation**:
   - The 1.3B model requires significant CPU resources
   - Consider reducing `max_length` parameter

4. **Model Download Fails**:
   - Manual download: `vagrant ssh` then run provision steps manually

### Performance Tips

- **For better performance**: Use a GPU-enabled setup (requires NVIDIA drivers)
- **For larger models**: Increase VM memory to 16GB+ and storage to 50GB+
- **For production**: Consider deploying on a physical server with dedicated GPU

## 🌟 Potential Enhancements

### Model Upgrades
- **6.7B Parameter Model**: Better quality, requires more resources
- **33B Parameter Model**: Enterprise-grade, requires significant hardware

### Feature Additions
- **Web Interface**: GUI for code generation
- **Batch Processing**: Handle multiple requests simultaneously
- **Model Fine-tuning**: Custom training on specific codebases
- **Multiple Languages**: Support for various programming languages

### Integration Options
- **VS Code Extension**: Direct IDE integration
- **CI/CD Pipeline**: Automated code review and generation
- **Database Backend**: Store and retrieve generated code snippets

## 📊 Model Specifications

- **Base Model**: DeepSeek Coder 1.3B Instruct
- **Architecture**: Transformer-based decoder
- **Training Data**: 2 trillion tokens of code
- **Supported Languages**: 80+ programming languages
- **Context Window**: 16,384 tokens
- **License**: MIT (commercial use allowed)

## 🤝 Contributing

This project is set up for easy customization:

1. Modify `api.py` for different API endpoints
2. Adjust `provision.sh` for different system configurations
3. Update `Vagrantfile` for different infrastructure needs

## 📄 License

The DeepSeek Coder model is licensed under MIT. This deployment code is open source and available for modification and distribution.

## 🔗 Resources

- [DeepSeek Coder GitHub](https://github.com/deepseek-ai/DeepSeek-Coder)
- [Hugging Face Model Page](https://huggingface.co/deepseek-ai/deepseek-coder-1.3b-instruct)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)

---

**Note**: This setup is designed for development and testing. For production workloads, consider deploying on dedicated hardware with GPU acceleration for optimal performance.
