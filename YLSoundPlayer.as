package {
  import Base64;

  import flash.system.Security;
  import flash.external.ExternalInterface;

  import flash.utils.*;

  import org.as3wavsound.WavSound;
  import org.as3wavsound.WavSoundChannel;

  import flash.display.Sprite;
  import flash.net.URLRequest;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.media.SoundMixer;
  import flash.events.Event;

  public class YLSoundPlayer extends Sprite {

    private var sound:Sound;
    private var wavSound:WavSound;
    private var wavSoundChannel:WavSoundChannel;
    private var soundChannel:SoundChannel;

    public function YLSoundPlayer() {
      //ExternalInterface.marshallExceptions = true;
      flash.system.Security.allowDomain('*')
      ExternalInterface.addCallback("play", play);
      ExternalInterface.addCallback("playBase64", playBase64);
    }

    private function play(url:String):void {
      trace("play: " + url);
      var req:URLRequest = new URLRequest(url);
      sound = new Sound();
      sound.addEventListener(Event.COMPLETE, soundFileLoaded);
      sound.load(req);
    }

    private function soundFileLoaded(event:Event):void {
      trace("sound file loaded!");
      ExternalInterface.call("startPlay");
      SoundMixer.stopAll();
      soundChannel = sound.play();
      soundChannel.addEventListener(Event.SOUND_COMPLETE, soundPlaybackEnded);
    }

    private function soundPlaybackEnded(event:Event):void {
      trace("sound playback ended");
      ExternalInterface.call("finishPlay");
    }

    private function playBase64(content:String):void {
      var wavSound:WavSound;
      var mp3Bytes:ByteArray;
      var wavBytes:ByteArray;
      if (wavSoundChannel) {
        wavSoundChannel.stop();
      }
      mp3Bytes = Base64.decodeToByteArray(content);
      wavSound = new WavSound(mp3Bytes);
      wavSoundChannel = wavSound.play();
    }
  }
}
