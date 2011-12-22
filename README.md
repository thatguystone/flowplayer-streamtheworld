# Flowplayer plugin to support MetaData from StreamTheWorld.com streams

For some unknown reason, StreamTheWorld sends their metadata in cuepoints that Flowplayer does not recognize.  This
plugin wraps the stream (I've only tested the .flv) and transforms onCuePoint stream events in flash into javascript
onMetaData events that are compatible with normal metadata events.

# Usage

Setup your clip to use "stw" as the provider; for example:

```javascript
	clip: {
		provider: 'stw',
		url: 'http://some.streatheworld/url'
	}
```

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

# Downloadable Plugin

Hit the download link and grab the plugin. You can use it just like any other plugin in flowplayer.

```javascript
	plugins: {
		stw: {
			url: 'flowplayer.stw-3.2.7.swf'
		}
	}
```
