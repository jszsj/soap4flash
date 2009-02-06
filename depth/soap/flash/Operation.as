package depth.soap.flash
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;
	
	public class Operation extends Proxy implements IEventDispatcher
	{
		public var nsWSDL:Namespace;
		public var nsSOAP:Namespace;
		public var nsSOAPENV:Namespace;
		public var targetNamespace:Namespace;
		private var _params:XMLList;
		private function get params():XMLList
		{
			if(_params == null)
			{
				var operationName:String = name;
				var aInputMessage:Array = String(webService.wsdl.nsWSDL::portType.(@name==webService.portType).nsWSDL::operation.(@name==operationName).nsWSDL::input.@message).split(":",2);				 
				var inputMessage:String = aInputMessage[aInputMessage.length-1];
				_params = webService.wsdl.nsWSDL::message.(@name==inputMessage).nsWSDL::part.@name;
			}
			return _params;
		}
		
		public function Operation(webService:WebService, name:String)
		{
			nsWSDL=webService.nsWSDL;
			nsSOAP=webService.nsSOAP;
			nsSOAPENV=webService.nsSOAPENV;
			targetNamespace=webService.targetNamespace;
			dispatcher=new EventDispatcher(this);
			
			
			this.webService = webService;
			this.name = name;
		}
		
		public var webService:WebService;
		private var _name:String;
		public function set name(value:String):void
		{
			_name = value;
			soapAction = webService.wsdl.nsWSDL::binding.(@name==webService.binding).nsWSDL::operation.(@name==value).nsSOAP::operation.@soapAction;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public var soapAction:String;
		public var lastResult:XML;
		private var _soapRequest:XML;
		public function get soapRequest():XML
		{
			if(_soapRequest == null)
			{
			_soapRequest = <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
							   <soapenv:Header/>
							   <soapenv:Body/>
							</soapenv:Envelope>				
			} 

			return _soapRequest;
		}
				
		public function send(args:Array = null):void
		{
			var arrayIndex:uint = 0;
			var operationRequest:XML = new XML("<"+name+"/>");
			operationRequest.setNamespace(targetNamespace);
			soapRequest.nsSOAPENV::Body.appendChild(operationRequest);
			for each(var paramValue:Object in args)
			{
				var paramName:String = params[arrayIndex];
				if(paramValue is XML) paramValue = paramValue.children(); 
				operationRequest.appendChild(new XML("<"+paramName+">"+paramValue+"</"+paramName+">"));
				arrayIndex++;
			}
			
			if(webService.username != null && webService.password != null)
			{
				var securityHeader = <wsse:Security soapenv:mustUnderstand="0" 
										xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" 
										xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope">
								         <wsse:UsernameToken wsu:Id="UsernameToken" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
								            <wsse:Username>{webService.username}</wsse:Username>
								            <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">{webService.password}</wsse:Password>
								         </wsse:UsernameToken>
								      </wsse:Security>
		      	soapRequest.nsSOAPENV::Header.appendChild(securityHeader);

			}
			var request:URLRequest=new URLRequest(webService.endpoint);
			request.method=URLRequestMethod.POST;
			request.requestHeaders.push(new URLRequestHeader("SOAPAction", soapAction));
			request.requestHeaders.push(new URLRequestHeader("Content-Type", "text/xml;charset=UTF-8"));
			request.data=soapRequest;
			
			var requestLoader:URLLoader = new URLLoader(request);
			requestLoader.addEventListener(Event.COMPLETE, soapRequestHandler);
			requestLoader.addEventListener(IOErrorEvent.IO_ERROR, soapRequestHandler);
			requestLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, soapRequestHandler);

			dispatcher.dispatchEvent(new WebServiceEvent(WebServiceEvent.REQUEST_SENT, soapRequest, true));
		}
				
		private function soapRequestHandler(event:Event):void
		{
			switch(event.type)
			{
				case Event.COMPLETE:
				lastResult = XML(event.target.data).nsSOAPENV::Body[0].children()[0];
				dispatcher.dispatchEvent(new WebServiceEvent(WebServiceEvent.RESULT));
				break;
				case IOErrorEvent.IO_ERROR:
				break;
				case SecurityErrorEvent.SECURITY_ERROR:
				break;
			}
		}
		
		/**
	     * @private
	     */
	    override flash_proxy function setProperty(name:*, value:*):void
	    {
	    	soapRequest[name] = value;
	    }
	    
	    private var dispatcher:EventDispatcher;

		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}

		public function dispatchEvent(evt:Event):Boolean
		{
			return dispatcher.dispatchEvent(evt);
		}

		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}

	}
}