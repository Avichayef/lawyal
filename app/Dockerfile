# Use Python 3.9 slim image
FROM python:3.9-slim

# working dir in the container
WORKDIR /app

# requirements
COPY requirements.txt .

# Install dependencies
# --no-cache-dir to reduce image size (not caching pip packages)
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask app into the container
COPY . .

# Expose port 5000 for Flask app
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=dev

# Run the Flask app
CMD ["python", "app.py"]
