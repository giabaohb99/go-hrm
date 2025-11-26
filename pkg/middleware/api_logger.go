package middleware

import (
	"bytes"
	"encoding/json"
	"io"
	"time"

	"github.com/myuser/go-hrm/pkg/model"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type responseWriter struct {
	gin.ResponseWriter
	body *bytes.Buffer
}

func (w *responseWriter) Write(b []byte) (int, error) {
	w.body.Write(b)
	return w.ResponseWriter.Write(b)
}

// APILogger is a global middleware that logs all API requests and responses
// This should be used by all microservices to maintain consistent logging
func APILogger(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Generate request ID
		requestID := uuid.New().String()
		c.Set("request_id", requestID)

		// Record start time (milliseconds)
		startTime := time.Now()
		startTimeMs := startTime.UnixMilli()

		// Read request body
		var requestBody string
		if c.Request.Body != nil {
			bodyBytes, _ := io.ReadAll(c.Request.Body)
			requestBody = string(bodyBytes)
			// Restore body for next handlers
			c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))
		}

		// Capture headers
		headersJSON, _ := json.Marshal(c.Request.Header)

		// Capture query params
		queryJSON, _ := json.Marshal(c.Request.URL.Query())

		// Create custom response writer to capture response
		responseBodyWriter := &responseWriter{
			ResponseWriter: c.Writer,
			body:           bytes.NewBufferString(""),
		}
		c.Writer = responseBodyWriter

		// Process request
		c.Next()

		// Record end time
		endTime := time.Now()
		endTimeMs := endTime.UnixMilli()
		responseTime := int(endTimeMs - startTimeMs)

		// Get response body
		responseBody := responseBodyWriter.body.String()

		// Extract domain from request body (for login endpoints)
		var requestData map[string]interface{}
		domain := ""
		if requestBody != "" {
			json.Unmarshal([]byte(requestBody), &requestData)
			if hostname, ok := requestData["hostname"].(string); ok {
				domain = hostname
			}
		}
		if domain == "" {
			domain = c.Request.Host
		}

		// Extract user context from gin context (set by auth middleware if authenticated)
		var userID, companyID, employeeID *uint
		if uid, exists := c.Get("user_id"); exists {
			if id, ok := uid.(uint); ok {
				userID = &id
			}
		}
		if cid, exists := c.Get("company_id"); exists {
			if id, ok := cid.(uint); ok {
				companyID = &id
			}
		}
		if eid, exists := c.Get("employee_id"); exists {
			if id, ok := eid.(uint); ok {
				employeeID = &id
			}
		}

		// Create API log entry
		apiLog := model.APILog{
			RequestID:      requestID,
			Method:         c.Request.Method,
			Endpoint:       c.Request.URL.Path,
			FullURL:        c.Request.URL.String(),
			UserID:         userID,
			CompanyID:      companyID,
			EmployeeID:     employeeID,
			IPAddress:      c.ClientIP(),
			IPForwarded:    c.GetHeader("X-Forwarded-For"),
			UserAgent:      c.GetHeader("User-Agent"),
			Referer:        c.GetHeader("Referer"),
			Origin:         c.GetHeader("Origin"),
			Domain:         domain,
			Host:           c.Request.Host,
			Headers:        string(headersJSON),
			QueryParams:    string(queryJSON),
			RequestBody:    requestBody,
			RequestSize:    len(requestBody),
			ResponseStatus: c.Writer.Status(),
			ResponseBody:   responseBody,
			ResponseSize:   len(responseBody),
			ResponseTime:   responseTime,
			TimestampStart: startTimeMs,
			TimestampEnd:   endTimeMs,
			Status:         1,
			DateCreated:    time.Now().Unix(),
			DateModified:   time.Now().Unix(),
		}

		// Extract error if exists
		if len(c.Errors) > 0 {
			apiLog.ErrorMessage = c.Errors.String()
		}

		// Save to database (async to not block response)
		go func() {
			db.Create(&apiLog)
		}()
	}
}
