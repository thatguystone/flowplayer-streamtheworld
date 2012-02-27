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
	import org.flowplayer.controller.ClipURLResolver;
	import org.flowplayer.controller.NetStreamControllingStreamProvider;
	import org.flowplayer.controller.StreamProvider;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.ClipEventType;
	import org.flowplayer.model.Plugin;
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.ProviderModel
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class StreamTheWorldProvider extends NetStreamControllingStreamProvider implements Plugin, ClipURLResolver {
		private var _model:PluginModel;
		private var _clip:Clip;
		
		private var _stream:String;
		private var _streams:XMLList;
		private var _currentStream:int;
		
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
			//requires modifications to FP core to work
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
		
		//for killing that lame xmlns that screws everything up
		private const XMLNS_PATTERN:RegExp = new RegExp('xmlns[^\"]*\"[^\"]*\"', 'gi');
		
		private var _failureListener:Function;
		
		private function _resolve(clip:Clip, successListener:Function):void {
			clip.url = 'http://' + _streams[_currentStream].ip + '/' + clip.url;
			_currentStream = ++_currentStream % _streams.length();
			successListener(clip);
		}
		
		public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
			//reset the STW streams tracking only if changing stations
			if (clip.url != _stream) {
				_stream = clip.url;
				_streams = null;
				_currentStream = 0;
			}
			
			if (_streams) {
				_resolve(clip, successListener);
				return;
			}
				
			var url:String = 'http://playerservices.streamtheworld.com/api/livestream?version=1.4&mount=' + clip.url + '&lang=en&nobuf=' + Math.random();
			var loader:URLLoader = new URLLoader(new URLRequest(url));
		
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var x:XML = new XML(e.target.data.replace(XMLNS_PATTERN, ''));
				
				if (x.descendants('status-code') != '200') {
					_failureListener();
					return;
				}
				
				_streams = x..mountpoints..server;
				_resolve(clip, successListener);
			});
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {
				_failureListener();
			});
			
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void {
				if (e.status != 200) {
					_failureListener();
				}
			});
		}
		
		public function set onFailure(listener:Function):void {
			_failureListener = listener;
		}
		
		public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
			return true;
		}
	}
}
