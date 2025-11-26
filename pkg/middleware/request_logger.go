package middleware

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type RequestLogWriter struct {
	gin.ResponseWriter
	body *bytes.Buffer
}

func (w *RequestLogWriter) Write(b []byte) (int, error) {
	w.body.Write(b)
	return w.ResponseWriter.Write(b)
}

// RequestLogger logs all incoming requests with detailed information
func RequestLogger() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Generate request ID
		requestID := uuid.New().String()
		c.Set("request_id", requestID)

		// Record start time
		startTime := time.Now()

		// Read request body
		var requestBody string
		if c.Request.Body != nil {
			bodyBytes, _ := io.ReadAll(c.Request.Body)
			requestBody = string(bodyBytes)
			// Restore body for next handlers
			c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))
		}

		// Capture response
		responseWriter := &RequestLogWriter{
			ResponseWriter: c.Writer,
			body:           bytes.NewBufferString(""),
		}
		c.Writer = responseWriter

		// Process request
		c.Next()

		// Calculate response time
		duration := time.Since(startTime)

		// Log request details
		logData := map[string]interface{}{
			"request_id":      requestID,
			"method":          c.Request.Method,
			"path":            c.Request.URL.Path,
			"query":           c.Request.URL.RawQuery,
			"status":          c.Writer.Status(),
			"response_time":   duration.Milliseconds(),
			"client_ip":       c.ClientIP(),
			"user_agent":      c.GetHeader("User-Agent"),
			"referer":         c.GetHeader("Referer"),
			"content_length":  c.Request.ContentLength,
			"response_size":   responseWriter.body.Len(),
		}

		// Add user context if available
		if userID, exists := c.Get("user_id"); exists {
			logData["user_id"] = userID
		}
		if companyID, exists := c.Get("company_id"); exists {
			logData["company_id"] = companyID
		}
		if employeeID, exists := c.Get("employee_id"); exists {
			logData["employee_id"] = employeeID
		}

		// Add request body for non-GET requests (be careful with sensitive data)
		if c.Request.Method != "GET" && len(requestBody) > 0 {
			// Mask sensitive fields
			var maskedBody map[string]interface{}
			if json.Unmarshal([]byte(requestBody), &maskedBody) == nil {
				maskSensitiveFields(maskedBody)
				logData["request_body"] = maskedBody
			}
		}

		// Add error if exists
		if len(c.Errors) > 0 {
			logData["errors"] = c.Errors.String()
		}

		// Convert to JSON and log
		if logJSON, err := json.Marshal(logData); err == nil {
			log.Printf("REQUEST_LOG: %s", string(logJSON))
		}
	}
}

// maskSensitiveFields masks sensitive information in request body
func maskSensitiveFields(data map[string]interface{}) {
	sensitiveFields := []string{"password", "token", "secret", "key", "auth"}
	
	for key, value := range data {
		keyLower := strings.ToLower(key)
		for _, sensitive := range sensitiveFields {
			if strings.Contains(keyLower, sensitive) {
				data[key] = "***MASKED***"
				break
			}
		}
		
		// Recursively mask nested objects
		if nested, ok := value.(map[string]interface{}); ok {
			maskSensitiveFields(nested)
		}
	}
}