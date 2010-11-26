package samples
{
	import depth.soap.flash.*;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ilyas stéphane Türkben
	 */
	public class EmailCheck extends Sprite 
	{
		private var webService:WebService;
		public function EmailCheck():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			webService = new WebService('http://ws.cdyne.com/emailverify/Emailvernotestemail.asmx?wsdl','EmailVerNoTestEmail','EmailVerNoTestEmailSoap');
			webService.addEventListener(WebServiceEvent.WSDL_LOADED, webServiceEventHandler);
		}
		
		private function webServiceEventHandler(event:WebServiceEvent):void {
				switch(event.type) {
					case WebServiceEvent.WSDL_LOADED:
					webService.VerifyEmail.addEventListener(WebServiceEvent.REQUEST_SENT, webServiceEventHandler);
					webService.VerifyEmail.addEventListener(WebServiceEvent.RESULT, webServiceEventHandler);
					webService.VerifyEmail.addEventListener(WebServiceEvent.FAULT, webServiceEventHandler);
					webService.VerifyEmail('email-at-domail.com');
					
					case WebServiceEvent.REQUEST_SENT:
						//	content of soap request
						trace(event.data);
					break;					
					case WebServiceEvent.RESULT:
						//	content of soap response
						trace(event.target.lastResult);
						//	accede to a specific value in the response
						trace(event.target.lastResult.*::VerifyEmailResult.*::ResponseText);
					break;
					case WebServiceEvent.FAULT:
						trace(event.target.lastResult);
					break;
				}
		}
	}
	
}