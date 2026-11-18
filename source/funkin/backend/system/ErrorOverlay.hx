package funkin.backend.system;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class ErrorOverlay extends Sprite {
	public static var enabled:Bool = true;

	/** Pesan error yang mengandung salah satu teks ini diabaikan (tidak memicu UI). */
	public static var ignored:Array<String> = [
		"asset with an ID of" // asset tidak ditemukan, misalnya font
	];

	/** Tulisan credit kecil di tengah atas. */
	public static var credit:String = "bf.Exe_Opt pr0gr4m";

	static var queue:Array<String> = [];
	static var instance:ErrorOverlay;
	static var inited:Bool = false;
	static var alreadyShown:Bool = false;

	/** Panggil sekali di Main. */
	public static function init():Void {
		if (inited) return;
		inited = true;
		Lib.current.addEventListener(Event.ENTER_FRAME, function(_) flush());
	}

	/** Boleh dipanggil dari mana saja, UI muncul di frame berikutnya. */
	public static function show(message:String):Void {
		if (!enabled || alreadyShown) return;
		for (p in ignored)
			if (message.indexOf(p) != -1) return;
		queue.push(message);
	}

	static function flush():Void {
		if (queue.length == 0 || alreadyShown) return;
		var msgs = queue;
		queue = [];
		alreadyShown = true;
		try {
			instance = new ErrorOverlay();
			Lib.current.stage.addChild(instance);
			var seen:Array<String> = [];
			for (m in msgs) {
				if (seen.indexOf(m) != -1) continue;
				seen.push(m);
				instance.addMessage(m);
			}
		} catch (e) {}
	}

	var messages:Array<String> = [];
	var body:TextField;

	function new() {
		super();
		var w:Float = Lib.current.stage.stageWidth;
		var h:Float = Lib.current.stage.stageHeight;
		var margin = w * 0.08;

		graphics.beginFill(0x000000, 0.88);
		graphics.drawRect(0, 0, w, h);
		graphics.endFill();

		// Credit kecil di tengah atas
		addChild(makeText(credit, Std.int(h * 0.028), 0x888888, 0, h * 0.015, w, h * 0.05, CENTER));

		addChild(makeText("ERROR", Std.int(h * 0.06), 0xFF5555, margin, h * 0.08, w - margin * 2, h * 0.1, LEFT));

		body = makeText("", Std.int(h * 0.04), 0xFFFFFF, margin, h * 0.2, w - margin * 2, h * 0.7, LEFT);
		body.wordWrap = true;
		body.multiline = true;
		addChild(body);

		// Tombol X di kanan atas
		var size = h * 0.1;
		var close = new Sprite();
		close.graphics.beginFill(0xCC3333);
		close.graphics.drawRoundRect(0, 0, size, size, 12, 12);
		close.graphics.endFill();
		close.addChild(makeText("X", Std.int(size * 0.55), 0xFFFFFF, 0, size * 0.15, size, size * 0.8, CENTER));
		close.x = w - size - h * 0.03;
		close.y = h * 0.03;
		close.addEventListener(MouseEvent.CLICK, function(_) dismiss());
		close.addEventListener(TouchEvent.TOUCH_END, function(_) dismiss());
		addChild(close);
	}

	function addMessage(m:String):Void {
		messages.push(m);
		var txt = messages.slice(0, 3).join("\n\n");
		if (messages.length > 3) txt += '\n\n(+${messages.length - 3} more)';
		body.text = txt;
	}

	function dismiss():Void {
		if (parent != null) parent.removeChild(this);
		instance = null;
	}

	static function makeText(text:String, size:Int, color:Int, x:Float, y:Float, w:Float, h:Float, align:TextFormatAlign):TextField {
		var tf = new TextField();
		tf.defaultTextFormat = new TextFormat("_sans", size, color, null, null, null, null, null, align);
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.x = x;
		tf.y = y;
		tf.width = w;
		tf.height = h;
		tf.text = text;
		return tf;
	}
}
