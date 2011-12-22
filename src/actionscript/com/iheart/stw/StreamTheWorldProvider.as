/*
 *	Copyright (c) 2011 Andrew Stone
 *	This file is part of flowplayer-streamtheworld.
 *
 *	flowplayer-streamtheworld is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	flowplayer-streamtheworld is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with flowplayer-streamtheworld.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.iheart.stw {
	import flash.net.NetStream;
	
	import org.flowplayer.controller.NetStreamControllingStreamProvider;
	import org.flowplayer.model.Plugin;
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.ClipEventType;

	public class StreamTheWorldProvider extends NetStreamControllingStreamProvider implements Plugin {
		private var _model:PluginModel;
		private var _clip:Clip;
		
		public function getDefaultConfig():Object {
			return null;
		}
		
		override public function onConfig(model:PluginModel):void {
			_model = model;
			_model.dispatchOnLoad();
		}
		
		override protected function doLoad(event:ClipEvent, netStream:NetStream, clip:Clip):void {
			super.doLoad(event, netStream, clip);
			_clip = clip;
			
			//hijack the netstream's cuepoint event
			//listening on "clip.onCuepoint" doesn't work properly as that is waiting on a clip event, not a stream event
			netStream.client.onCuePoint = onCuePoint;
		}
		
		private function onCuePoint(info:Object):void {
			var obj:Object = {};
			
			obj['eventName'] = info['name'];
			
			for (var i:String in info["parameters"]) {
				obj[i] = info["parameters"][i];
			}
			
			_clip.metaData = obj;
			_clip.dispatch(ClipEventType.METADATA);
		}
	}
}
