global class RESTProcessLeadResponse 
{
	public boolean Success;
    public integer StatusCode;
    public string Message;
    public string Request;     
    
    global RESTProcessLeadResponse(boolean success, integer statusCode, string message, string request)
    {
        this.Success = success;
        this.StatusCode = statusCode;
        this.Message = message;
        this.Request = request;
    }
}