package org.bigbluebutton.modules.whiteboard.views.annotations
{
	import org.bigbluebutton.modules.whiteboard.business.shapes.AnnotationDisplayFactory;
	import org.bigbluebutton.modules.whiteboard.business.shapes.TextObject;
	import org.bigbluebutton.modules.whiteboard.business.shapes.WhiteboardConstants;
	import org.bigbluebutton.modules.whiteboard.events.WhiteboardDrawEvent;
	import org.bigbluebutton.modules.whiteboard.models.Annotation;
	import org.bigbluebutton.modules.whiteboard.views.WhiteboardCanvas;
	import org.bigbluebutton.modules.whiteboard.views.models.WhiteboardTool;

	public class TextBuilder implements IBuilder
	{
		private var _wbCanvas:WhiteboardCanvas;
		private var _sendFrequency:int;
		private var _shapeFactory:AnnotationDisplayFactory;
		private var _textStatus:String = TextObject.TEXT_CREATED;
		private var _mouseXDown:Number = 0;
		private var _mouseYDown:Number = 0;
		
		public function TextBuilder(wbCanvas:WhiteboardCanvas, sendShapeFrequency:int, shapeFactory:AnnotationDisplayFactory)
		{
			_wbCanvas = wbCanvas;
			_sendFrequency = sendShapeFrequency;
			_shapeFactory = shapeFactory;
		}
		
		public function onMouseDown(mouseX:Number, mouseY:Number, tool:WhiteboardTool):void
		{
			if (tool.graphicType == WhiteboardConstants.TYPE_TEXT) {
				_mouseXDown = mouseX;
				_mouseYDown = mouseY;
			}
		}
		
		public function onMouseMove(mouseX:Number, mouseY:Number, tool:WhiteboardTool):void
		{
			// do nothing
		}
		
		public function onMouseUp(mouseX:Number, mouseY:Number, tool:WhiteboardTool):void
		{
			if (tool.graphicType == WhiteboardConstants.TYPE_TEXT) {
				var tbWidth:Number = mouseX - _mouseXDown;
				var tbHeight:Number = mouseY - _mouseYDown;
				
				if (tbHeight < 15 || tbWidth < 50) return;
				
				var tobj:TextObject = _shapeFactory.createTextObject("", 0x000000, 0x000000, false, _mouseXDown, _mouseYDown, tbWidth, tbHeight, 18);
				sendTextToServer(TextObject.TEXT_CREATED, tobj);                    
			}        
		}
		
		private function sendTextToServer(status:String, tobj:TextObject):void {
			switch (status) {
				case TextObject.TEXT_CREATED:
					tobj.status = TextObject.TEXT_CREATED;
					_textStatus = TextObject.TEXT_UPDATED;
					break;
				case TextObject.TEXT_UPDATED:
					tobj.status = TextObject.TEXT_UPDATED;
					break;
				case TextObject.TEXT_PUBLISHED:
					tobj.status = TextObject.TEXT_PUBLISHED;
					_textStatus = TextObject.TEXT_CREATED;
					break;
			}	
						
			var annotation:Object = new Object();
			annotation["type"] = "text";
			annotation["id"] = tobj.getGraphicID();
			annotation["status"] = tobj.status;  
			annotation["text"] = tobj.text;
			annotation["fontColor"] = tobj.textColor;
			annotation["backgroundColor"] = tobj.backgroundColor;
			annotation["background"] = tobj.background;
			annotation["x"] = tobj.getOrigX();
			annotation["y"] = tobj.getOrigY();
			annotation["fontSize"] = tobj.textSize;
			annotation["textBoxWidth"] = tobj.textBoxWidth;
			annotation["textBoxHeight"] = tobj.textBoxHeight;
			
			var msg:Annotation = new Annotation(tobj.getGraphicID(), "text", annotation);
			_wbCanvas.sendGraphicToServer(msg, WhiteboardDrawEvent.SEND_TEXT);			
		}
	}
}