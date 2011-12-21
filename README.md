# Flowplayer plugin to support MetaData from StreamTheWorld.com streams

For some unknown reason, StreamTheWorld sends their metadata in cuepoints that Flowplayer does not recognize.  This
plugin wraps the stream (I've only tested the .flv) and transforms onCuePoint stream events in flash into javascript
onMetaData events that are compatible with normal metadata events.

# Compile

Add this as a plugin to your flowplayer compilation (how to compile flowplayer is outside this scope), and update your
BuiltInConfig.as with the following:

```actionscript
	package  {
		import com.iheart.stw.StreamTheWorld;

		public class BuiltInConfig {
			private var stw:StreamTheWorld;
		
			public static const config:Object = { 
					stw: {
						"url": "com.iheart.stw.StreamTheWorld"
					}
				}
			};
		}
	}
```
