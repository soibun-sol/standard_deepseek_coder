# api.py - Use this for local editing
try:
    # These will work in VM
    from fastapi import FastAPI, HTTPException
    from pydantic import BaseModel
    from transformers import AutoModelForCausalLM, AutoTokenizer
    import torch
    import uvicorn
except ImportError:
    # Mock imports for local development
    pass

# Your actual code continues here... set this up to bypass import errors during local editing

app = FastAPI(title="DeepSeek Coder API")

# Global variables for model and tokenizer
model = None
tokenizer = None

class CodeRequest(BaseModel):
    prompt: str
    max_length: int = 512
    temperature: float = 0.7
    top_p: float = 0.95

class CodeResponse(BaseModel):
    generated_code: str
    status: str

@app.on_event("startup")
async def load_model():
    global model, tokenizer
    try:
        print("Loading DeepSeek Coder model...")
        
        # Adjust model name based on which one you downloaded
        model_name = "deepseek-ai/deepseek-coder-1.3b-instruct"
        
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        model = AutoModelForCausalLM.from_pretrained(
            model_name,
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True
        )
        
        print("Model loaded successfully!")
    except Exception as e:
        print(f"Error loading model: {e}")
        raise e

@app.post("/generate", response_model=CodeResponse)
async def generate_code(request: CodeRequest):
    if model is None or tokenizer is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        # Format prompt for code generation
        formatted_prompt = f"### Instruction:\n{request.prompt}\n\n### Response:"
        
        inputs = tokenizer.encode(formatted_prompt, return_tensors="pt")
        
        with torch.no_grad():
            outputs = model.generate(
                inputs,
                max_length=request.max_length,
                temperature=request.temperature,
                top_p=request.top_p,
                do_sample=True,
                pad_token_id=tokenizer.eos_token_id
            )
        
        generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        generated_code = generated_text.split("### Response:")[-1].strip()
        
        return CodeResponse(
            generated_code=generated_code,
            status="success"
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Generation error: {str(e)}")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_loaded": model is not None}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)