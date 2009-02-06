package depth.soap.flash
{
	import flash.events.Event;
	
	public dynamic class WebServiceEvent extends Event
	{
		public static const WSDL_LOADED:String = "wsdlLoaded";
		public static const REQUEST_SENT:String = "requestSent";
		public static const RESULT:String = "result";
		public static const FAULT:String = "fault";
		
		
		public function WebServiceEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		

	}
}