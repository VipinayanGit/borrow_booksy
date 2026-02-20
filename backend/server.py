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

@app.route("/process_image", methods=['POST'])
def process_image():
    print("📥 Request received!")
    try:
        if 'image' not in request.files:
            return jsonify({"error": "no image provided"})

        print("📂 Files received:", request.files)

        image_file = request.files['image']
        img = Image.open(io.BytesIO(image_file.read()))

        print("📸 Image received from Flutter")

        prompt = """
        From this book cover image, extract:
        1. Book title
        2. Author name

        Return the result strictly in this JSON format:

        {
          "title": "book title here",
          "author": "author name here"
        }

        Rules:
        - If no title is found return "no title"
        - If image doesn't look like a book front page return:
          {
            "title": "not a book",
            "author": null
          }
        - If no author is found return "no author name"
        """

        response = model.generate_content([prompt, img])
        print("✅ Gemini processed the image")

        gemini_text = response.text
        gemini_text = gemini_text.replace("```json", "").replace("```", "").strip()

        parsed = json.loads(gemini_text)

        return jsonify({
            "status": "success",
            "title": parsed.get("title"),
            "author": parsed.get("author")
        })

    except Exception as e:
        print("❌ Error:", str(e))
        return jsonify({"error": str(e)}), 500

if __name__ =='__main__':
    app.run(host='0.0.0.0',port=int(os.environ.get("PORT", 5000)),debug=True)




