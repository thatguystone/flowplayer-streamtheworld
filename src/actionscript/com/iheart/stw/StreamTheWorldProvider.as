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
	
	import org.flowplayer.controller.ClipURLResolver;
	import org.flowplayer.controller.NetStreamControllingStreamProvider;
	import org.flowplayer.controller.StreamProvider;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.ClipEventType;
	import org.flowplayer.model.Plugin;
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.ProviderModel
	
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	public class StreamTheWorldProvider extends NetStreamControllingStreamProvider implements Plugin, ClipURLResolver {
		private var _model:PluginModel;
		private var _clip:Clip;
		
		/**
		 * Default plugin stuffs
		 * ------------------------------------------------------------------------------------------------------------
		 */
		
		public function getDefaultConfig():Object {
			return null;
		}
		
		override public function onConfig(model:PluginModel):void {
			_model = model;
			
			//force flowplayer to use THIS plugin as the url resolver, too
			(_model as ProviderModel).urlResolver = "stw";
			
			_model.dispatchOnLoad();
		}
		
		override protected function doLoad(event:ClipEvent, netStream:NetStream, clip:Clip):void {
			super.doLoad(event, netStream, clip);
			_clip = clip;
			
			//hijack the netstream's cuepoint event
			//listening on "clip.onCuepoint" doesn't work properly as that is waiting on a clip event, not a stream event
			netStream.client.onCuePoint = onCuePoint;
		}
		
		/**
		 * Cuepoint -> Metadata fix
		 * ------------------------------------------------------------------------------------------------------------
		 */
		
		private function onCuePoint(info:Object):void {
			var obj:Object = {};
			
			obj['eventName'] = info['name'];
			
			for (var i:String in info["parameters"]) {
				obj[i] = info["parameters"][i];
			}
			
			_clip.metaData = obj;
			_clip.dispatch(ClipEventType.METADATA);
		}
		
		/**
		 * ClipUrlResolver stuff
		 * ------------------------------------------------------------------------------------------------------------
		 */
		
		private var _failureListener:Function;

		public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
			log.info('I MADE IT');
			_clip = clip;
			if (successListener != null) {
				successListener(clip);
			}
		}

		public function set onFailure(listener:Function):void {
			_failureListener = listener;
		}

		public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
			return true;
		}
	}
}
