# Dockerfile for AI Stock Predictions Flask App

# 1. Base Image: Use an official Python runtime as a parent image
# Using python:3.11 to match your environment indicated in previous logs.
# '-slim' variants are smaller than the full images. '-bullseye' is a common stable Debian version.
FROM python:3.11-slim-bullseye

# 2. Set Environment Variables
# Prevents Python from buffering stdout/stderr, making logs appear immediately
ENV PYTHONUNBUFFERED=1
# Set the port the application will run on inside the container
# Note: Gunicorn's --bind doesn't directly use $PORT in CMD exec form easily,
# so we'll use 8080 directly in CMD, matching EXPOSE.
ENV PORT=8080
# Set the working directory inside the container
WORKDIR /app

# 3. Install Dependencies
# Copy *only* the requirements file first to leverage Docker cache
# If requirements.txt hasn't changed, Docker won't re-run pip install
COPY requirements.txt .

# Install dependencies specified in requirements.txt
# --no-cache-dir reduces image size by not storing the pip cache
# --upgrade pip ensures the latest pip is used
# Added space before && for clarity/safety
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 4. Copy Application Code
# Copy the rest of your application code into the container's working directory
# This will create /app/ai-stock-predictions/, /app/app.py etc. if your structure is like that
COPY . .

# 5. Expose Port
# Inform Docker that the container listens on the specified port at runtime
EXPOSE 8080

# 6. Define Start Command (Corrected)
# Use the JSON array (exec) form for CMD.
# Each argument is a separate string in the list.
# --chdir changes the directory *before* Gunicorn looks for app:app
# Ensure 'app:app' corresponds to your Flask app object 'app' in the file 'app.py'
# located inside the 'ai-stock-predictions' directory relative to WORKDIR /app.
CMD ["gunicorn", "--chdir", "/app/ai-stock-predictions", "--timeout", "120", "--bind", "0.0.0.0:8080", "app:app"]