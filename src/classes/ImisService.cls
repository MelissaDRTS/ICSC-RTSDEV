public with sharing class ImisService
{
	/*public static ImisAccount getAccount(string imisId)
	{
		ImisAccount acct = null;
		string jsonAccount = request('http://64.14.178.228/v1.6/users/' + imisId, null);

		return acct;
	}

	public static String getAccountData(DateTime lastModifiedDate, integer start, integer numberOfRecords)
	{
		return request('http://64.14.178.228/v1.6/accounts/' + string.valueOf(start) + '/' + string.valueOf(numberOfRecords), lastModifiedDate);
	}*/

	public static String getAccountData(String endPoint, DateTime lastModifiedDate, integer start, integer numberOfRecords, string token)
	{
		return request(endPoint + string.valueOf(start) + '/' + string.valueOf(numberOfRecords), lastModifiedDate, token);
	}

	public static String getAccountSalesSummaryData(String endPoint, String year, integer start, string token)
	{
		return request(endPoint + string.valueOf(year) + '/' + string.valueOf(start), null, token);
	}

	public static String getBoothSalesHistory(String endPoint, String year, integer start, string token)
	{
		return request(endPoint + string.valueOf(year) + '/' + string.valueOf(start), null, token);
	}

	public static String getSponsorshipSalesHistory(String endPoint, String year, integer start, string token)
	{
		return request(endPoint + string.valueOf(year) + '/' + string.valueOf(start), null, token);
	}

    public static String getRequestUrl(String endPoint, String year, integer start, string token){
        return endPoint + string.valueOf(year) + '/' + string.valueOf(start);
    }

	public static String getValidationTable(string endPoint, string token)
	{
		return request(endPoint, null, token);
	}

	public static String request(String endPoint, DateTime lastModified, string token)
	{
		HttpRequest req = new HttpRequest();
                Http http = new Http();
                HTTPResponse res = null;
                String body = null;

                req.setEndpoint(endPoint);
                req.setMethod('GET');

                if(lastModified != null)
                {
                	req.setHeader('If-Modified-Since', lastModified.formatGmt('EEE, MMM d yyyy HH:mm:ss') + ' GMT');
                }

                if(token != null)
                {
                	req.setHeader('Client-Token', token);
                }
                System.debug('req: ' + req);
                System.debug('req.header Client-Token: ' + req.getHeader('Client-Token'));
                System.debug('req.header If-Modified-Since: ' + req.getHeader('If-Modified-Since'));
                req.setTimeout(20000);
                res = http.send(req);

                if(res.getStatusCode() == 304) //No changes found
                {
                	body = null;
                }
                else if(res.getStatusCode() == 200) //Ok to proceed
                {
                	body = res.getBody();
                }
                else //Error
                {
                	throw new ImisServiceException('Status Code: ' + res.getStatusCode() + ' -- Status: ' + res.getStatus());
                }

        System.debug('body: ' + body);
                return body;
	}

	public static String put(String endPoint, String jsonData, string token)
	{
		HttpRequest req = new HttpRequest();
                Http http = new Http();
                HTTPResponse res = null;
                String body = null;

                req.setEndpoint(endPoint);
                req.setMethod('PUT');
                req.setBody(jsonData);
                req.setHeader('ContentType', 'application/json');

                if(token != null)
                {
                	req.setHeader('Client-Token', token);
                }

                res = http.send(req);

                if(res.getStatusCode() == 200) //Ok to proceed
                {
                	body = res.getBody();
                }
                else //Error
                {
                	throw new ImisServiceException('Status Code: ' + res.getStatusCode() + ' -- Status: ' + res.getStatus());
                }

                return body;
	}
}