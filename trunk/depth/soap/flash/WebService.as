package depth.soap.flash
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	/**
	 * SOAP Webservice class. Compatible only with RPC literal documents. 
	 * */
	public dynamic class WebService extends Proxy implements IEventDispatcher
	{

		public var operations:Array;
		public var nsWSDL:Namespace;
		public var nsSOAP:Namespace;
		public var nsSOAPENV:Namespace;
		public var nsXMLSchema:Namespace;
		public var targetNamespace:Namespace;

		public function WebService(wsdlURI:String=null, service:String=null, port:String=null, username:String=null, password:String=null)
		{
			nsWSDL=new Namespace("http://schemas.xmlsoap.org/wsdl/");
			nsSOAP=new Namespace("http://schemas.xmlsoap.org/wsdl/soap/");
			nsSOAPENV = new Namespace("http://schemas.xmlsoap.org/soap/envelope/");
			nsXMLSchema = new Namespace("http://www.w3.org/2001/XMLSchema");
			dispatcher=new EventDispatcher(this);

			this.username=username;
			this.password=password;
			this.service=service;
			this.port=port;
			this.wsdlURI=wsdlURI;

		}

		public var username:String;
		public var password:String;

		private var _service:String;

		public function set service(value:String):void
		{
			_service=value;
		}
		public function get service():String
		{
			if (_service == null)
			{
				if (wsdl != null)
				{
					service=wsdl.nsWSDL::service[0].@name;
				}
			}

			return _service;
		}

		private var _port:String;

		public function set port(value:String):void
		{
			_port=value;
		}
		public function get port():String
		{
			if (_port == null)
			{
				if (wsdl != null)
				{
					port=wsdl.nsWSDL::service.(@name==service).nsWSDL::port[0].@name;
				}
			}

			return _port;
		}

		private var _endpoint:String;

		public function set endpoint(value:String):void
		{
			_endpoint=value;
		}
		public function get endpoint():String
		{
			if (_endpoint == null)
			{
				if (wsdl != null)
				{
					endpoint=wsdl.nsWSDL::service.(@name==service).nsWSDL::port.(@name==port).nsSOAP::address.@location;
				}
			}

			return _endpoint;
		}

		private var _binding:String;

		public function set binding(value:String):void
		{
			_binding=value;
		}
		public function get binding():String
		{
			if (_binding == null)
			{
				if (wsdl != null)
				{
					var nsBinding:Array = String(wsdl.nsWSDL::service.(@name==service).nsWSDL::port[0].@binding).split(":",2); 
					binding=nsBinding[nsBinding.length-1];
				}
			}

			return _binding;
		}
		
		
		private var _portType:String;

		public function set portType(value:String):void
		{
			_portType=value;
		}
		public function get portType():String
		{
			if (_portType == null)
			{
				if (wsdl != null)
				{
					var nsPortTypes:Array = String(wsdl.nsWSDL::binding.(@name==binding).@type).split(":",2); 
					portType=nsPortTypes[nsPortTypes.length-1];
				}
			}

			return _portType;
		}

		private var _wsdlURI:String;

		public function set wsdlURI(value:String):void
		{
			if (value != null)
			{
				_wsdlURI=value;
				getHTTPResource(value, loadWSDLhandler);
			}
			else
				wsdl=null;
		}

		public function get wsdlURI():String
		{
			return _wsdlURI;
		}


		private var _wsdl:XML;
		public function set wsdl(value:XML):void
		{
			_wsdl=value;
			operations=new Array();
			if(value != null)
			{
				targetNamespace = new Namespace(value.@targetNamespace);
				dispatcher.dispatchEvent(new WebServiceEvent(WebServiceEvent.WSDL_LOADED));
				
			}		
		}
		public function get wsdl():XML
		{
			return _wsdl;
		}		

		private function getHTTPResource(uri:String, handler:Function):*
		{
			var request:URLRequest=new URLRequest(uri);
			request.method=URLRequestMethod.GET;
			var requestLoader:URLLoader=new URLLoader(request);
			requestLoader.addEventListener(Event.COMPLETE, handler);
			requestLoader.addEventListener(IOErrorEvent.IO_ERROR, handler);
			requestLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);
		}

		private function loadWSDLhandler(event:Event):void
		{
			switch(event.type)
			{
				case Event.COMPLETE:
					wsdl=new XML(event.target.data);
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
		override flash_proxy function getProperty(name:*):*
		{
			var operation:Operation = operations[name];
			if(operation == null)
			{
				operation = new Operation(this, name);
				operations[name] = operation;	
			}
			return operation;
		}
		
	/**
	     * @private
	     */
	    override flash_proxy function callProperty(name:*, ... args:Array):*
	    {
			var operation:Operation = operations[name];
			if (!operation) operation = getProperty(name);
			operation.send(args);
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
