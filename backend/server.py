import google.generativeai as genai
from PIL import Image
from flask import Flask, request, jsonify
import json
import io
from dotenv import load_dotenv
import os 

load_dotenv()
api_key = os.getenv("API_KEY")

if not api_key:
    raise ValueError("GENAI_API_KEY not found in .env file")

genai.configure(api_key=api_key)
print("API key loaded:", api_key is not None)

model=genai.GenerativeModel("gemini-2.5-flash")

app=Flask(__name__)

@app.route("/process_image",methods=['POST'])
def process_image():
    print("📥 Request received!") 
    try:
        if 'image' not in request.files:
            return jsonify({"error" :"no image provided"})
        
        print("📂 Files received:", request.files)
        image_file=request.files['image']
        img=Image.open(io.BytesIO(image_file.read()))

        print("image received from flutter")
        si="Give me the title  of the book only,if there is no title just return no title,if the image doesn't look like a book front page just return not a book"

        response=model.generate_content([si,img])
        print("✅ Gemini processed the image")
         
        gemini_text = response.text if hasattr(response, "text") else str(response)




        return jsonify({
            "status": "success",
            "gemini_response":gemini_text
        })
    
    except Exception as e:
        print("❌ Error:", str(e))
        return jsonify({"error": str(e)}), 500

if __name__ =='__main__':
    app.run(host='0.0.0.0',port=int(os.environ.get("PORT", 5000)),debug=True)




