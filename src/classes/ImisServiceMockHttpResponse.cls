@isTest
global class ImisServiceMockHttpResponse implements HttpCalloutMock
{
	global HTTPResponse respond(HTTPRequest req) 
	{
        if(req.getEndpoint().startsWith('http://64.14.178.228/v1.6/accounts/'))
        {
        	return getImisAccountDataResponse();
        }
        else if(req.getEndpoint().startsWith('http://64.14.178.228/v1.6/accounts/'))
        {
        	if(req.getMethod().toLowerCase() == 'put')
        	{
        		return updateImisAccountDataResponse();
        	}
        }
        else if(req.getEndpoint().startsWith('http://64.14.178.228/v1.6/validationtables/primary'))
        {
        	return getImisValidationTableDataResponse();
        }
        else if(req.getEndpoint().startsWith('http://64.14.178.228/v1.6/blacktab/sponsorship/'))
        {
        	return getImisSponsorshipSalesHistoryDataResponse();
        }
        else if(req.getEndpoint().startsWith('http://64.14.178.228/v1.6/blacktab/booth/'))
        {
        	return getImisBoothSalesHistoryDataResponse();
        }
        else if(req.getEndpoint().startsWith('http://64.14.178.228/v1.6/blacktab/summary/'))
        {
        	return getImisAccountSalesSummaryDataResponse();
        }
        else if(req.getEndpoint().startsWith('http://304.com'))
        {
        	return get304Response();
        }
        else if(req.getEndpoint().startsWith('http://404.com'))
        {
        	return get404Response();
        }
        
        
        return null;
    }
    
    private HTTPResponse getImisAccountDataResponse()
    {
    	string jsonData = '{"imis":{"data":{"@start":"0","@count":"5","accounts":{"account":[{"id":"116441","company":"Mall of Orange","status":"S","membertype":"RM","address":"2298 N Orange Mall","city":"Orange",' 
					+ '"state":"CA","zip":"92865-3610","country":"United States","phone":"(714) 998-1521","fax":"(714) 998-6378","paidthru":"2003-02-28"},{"id":"128743","company":"Grebar Holdings, LLC",' 
					+ '"status":"S","membertype":"AM","address":"30911 N. 138th Street","city":"Scottsdale","state":"AZ","zip":"85262","country":"United States","phone":"970-390-9460","fax":null,'
					+ '"paidthru":"2012-04-30"},{"id":"146269","company":"F.C. Tucker Company Incorporated","status":"S","membertype":"RM","address":"11711 Landings Dr","city":"Indianapolis","state":"IN",' 
					+ '"zip":"46256-9437","country":"United States","phone":null,"fax":null,"paidthru":null},{"id":"172774","company":"Motor City LLC","status":"S","membertype":"NM",' 
					+ '"address":"450 E Waterside Drive","city":"Chicago","state":"IL","zip":"60601-5004","country":"United States","phone":"(312) 540-1089","fax":"(312) 861-0553","paidthru":"2000-04-30"},'
					+ '{"id":"230042","company":"Olivia\'s Salad","status":"S","membertype":"AM","address":"4790 Irvine Blvd.","city":"Irvine","state":"CA","zip":"92620-1998","country":"United States",' 
					+ '"phone":"(415) 235-5064","fax":null,"paidthru":"2005-04-30"}]}},"errors":{"message":null,"warning":null}}}';
					
    	return buildResponse(jsonData, 200);
    }
    
     private HTTPResponse updateImisAccountDataResponse()
    {
    	return buildResponse('{"success":"true"}', 200);
    }
    
    private HTTPResponse getImisValidationTableDataResponse()
    {
    	string jsonData = '{"imis":{"data":{"@count":"5","values":{"value":[{"code":"ACA","description":"Academic Institution"},{"code":"PRF","description":"Accounting, Auditing and Tax Services"},' 
    					+ '{"code":"ADV","description":"Advertising/Marketing/PR"},{"code":"ARC","description":"Architecture/Design/Engineering"},' 
    					+ '{"code":"UTL","description":"Utilities, Telecommunications and Other Services"}]}},"errors":{"message":null,"warning":null}}}';
					
    	return buildResponse(jsonData, 200);
    }
    
    private HTTPResponse getImisAccountSalesSummaryDataResponse()
    {
    	string jsonData = '{"imis":{"data":{"@count":"1","summary":{"detail":{"@year":"2013","account":[{"id":"1568686","fundraising":"0.00","dues":"375.00","pac":"0.00","certification":"0.00","registration":"21833.44","foundation":"0.00","refunds":"0.00"},' + 
    						'{"id":"1570303","fundraising":"0.00","dues":"1800.00","pac":"0.00","certification":"0.00","registration":"13863.05","foundation":"0.00","refunds":"0.00"},' + 
    						'{"id":"1571567","fundraising":"0.00","dues":"0.00","pac":"0.00","certification":"0.00","registration":"20142.40","foundation":"0.00","refunds":"0.00"},' + 
    						'{"id":"1572878","fundraising":"0.00","dues":"1850.00","pac":"225.00","certification":"0.00","registration":"11740.00","foundation":"0.00","refunds":"0.00"},' + 
    						'{"id":"1579368","fundraising":"0.00","dues":"0.00","pac":"0.00","certification":"0.00","registration":"25087.21","foundation":"0.00","refunds":"0.00"}]}}},"errors":{"message":null,"warning":null}}}';
					
    	return buildResponse(jsonData, 200);
    }
    
    private HTTPResponse getImisBoothSalesHistoryDataResponse()
    {
    	string jsonData = '{"imis":{"data":{"@count":"1936","@year":"2013","meetings":{"meeting":[{"code":"WS2014","id":"1025154","salestype":"BOOTH","description":"10 X 10","quantity":"1.00","cost":"470.00","boothcontact":"Jacqui  Greenlaw","boothcontactemail":"jkg@excessspace.com","boothnumber":null,"orderdate":"2013-12-18"}, ' + 
							'{"code":"WS2014","id":"1009474","salestype":"BOOTH2","description":"Leasing Suite 3,000sqft","quantity":"1.00","cost":"7300.00","boothcontact":"Gael  Courtney","boothcontactemail":"gcourtney@flockavoyer.com","boothnumber":null,"orderdate":"2013-12-18"},' + 
							'{"code":"WS2014","id":"1002319","salestype":"BOOTH","description":"10 X 10","quantity":"1.00","cost":"470.00","boothcontact":"Victoria  Greene","boothcontactemail":"vgreene@firstam.com","boothnumber":null,"orderdate":"2013-12-18"},' + 
							'{"code":"WS2014","id":"1034192","salestype":"BOOTH","description":"10 X 10","quantity":"4.00","cost":"1880.00","boothcontact":"Joanne  Calabrese","boothcontactemail":"joanne@albdev.com","boothnumber":null,"orderdate":"2013-12-19"},' + 
							'{"code":"WS2014","id":"1006188","salestype":"BOOTH1","description":"Leasing Suite 1,500sqft","quantity":"1.00","cost":"3800.00","boothcontact":"Kathy  Lattman","boothcontactemail":"kathy@sudprop.com","boothnumber":null,"orderdate":"2013-12-20"},' + 
							'{"code":"WS2014","id":"1001697","salestype":"BOOTH","description":"10 X 10","quantity":"4.00","cost":"1880.00","boothcontact":"Brianne  Hession","boothcontactemail":"brianne@journeycommunications.com","boothnumber":null,"orderdate":"2013-12-24"},' + 
							'{"code":"WS2014","id":"1051384","salestype":"BOOTH","description":"10 X 10","quantity":"5.00","cost":"2350.00","boothcontact":"Sara  Stewart","boothcontactemail":"sstewart@farislee.com","boothnumber":null,"orderdate":"2013-12-24"},' + 
							'{"code":"WS2014","id":"1056951","salestype":"BOOTH","description":"10 X 10","quantity":"2.00","cost":"940.00","boothcontact":"Dawn  Johnson","boothcontactemail":"djohnson@boosdevelopment.com","boothnumber":null,"orderdate":"2013-12-30"},' + 
							'{"code":"WS2014","id":"1003844","salestype":"BOOTH1","description":"Leasing Suite 1,500sqft","quantity":"1.00","cost":"3800.00","boothcontact":"Sam  Carpenter","boothcontactemail":"sam.carpenter@lewisop.com","boothnumber":null,"orderdate":"2013-12-31"}]}},"errors":{"message":null,"warning":null}}}';
					
    	return buildResponse(jsonData, 200);
    }
    
    private HTTPResponse getImisSponsorshipSalesHistoryDataResponse()
    {
    	string jsonData = '{"imis":{"data":{"@count":"871","meetings":{"@year":"2013","meeting":[{"code":"2013CAS","id":"1548889","meetingtitle":"Canadian Shopping Centre Awards Sponsorship","meetingdate":"2013-09-16","productcode":"2013CAS/RC","functiontitle":"Gold Sponsorship","quantity":"1.000000","amount":"5500.00","orderdate":"2013-08-08"},' +  
    						'{"code":"2013CCS","id":"1568686","meetingtitle":"Canadian Convention Deal Making and Trade Expo Sponsorship","meetingdate":"2013-09-16","productcode":"2013CCS/RC","functiontitle":"Platinum Sponsorship","quantity":"1.000000","amount":"13000.00","orderdate":"2013-09-16"},' + 
    						'{"code":"2013S45S","id":"1570303","meetingtitle":"Vancouver Retail Program Sponsorship","meetingdate":"2013-09-05","productcode":"2013S45S/RC","functiontitle":"Sponsorship","quantity":"1.000000","amount":"500.00","orderdate":"2013-10-03"},' + 
    						'{"code":"2013N90S","id":"1570303","meetingtitle":"Montreal Next Generation Program Sponsorship","meetingdate":"2013-11-13","productcode":"2013N90S/RC","functiontitle":"Sponsorship","quantity":"1.000000","amount":"500.00","orderdate":"2013-10-25"},' + 
    						'{"code":"2013APCS","id":"1571567","meetingtitle":"RECon Asia Sponsorship","meetingdate":"2013-12-02","productcode":"2013APCS/RC4","functiontitle":"Silver Sponsorship","quantity":"1.000000","amount":"19000.00","orderdate":"2013-09-09"}]}},"errors":{"message":null,"warning":null}}}';
					
    	return buildResponse(jsonData, 200);
    }
    
    private HTTPResponse get304Response()
    {
    	return buildResponse('', 304);
    }
    
    private HTTPResponse get404Response()
    {
    	return buildResponse('', 404);
    }
    
    private HttpResponse buildResponse(string jsonData, Integer statusCode)
    {
    	HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonData);
        res.setStatusCode(statusCode);
        return res;
    }
    
}