import std.stdio;
import rcld;
import std_msgs.msg : String;
import core.thread;
import std.format;

void main() {
    init();

    auto node = new Node("talker", "");
    auto pub = new Publisher!String(node, "/chatter");

    foreach (i; 0 .. 10) {
        Thread.sleep(1.seconds);

        auto msg = String();
        msg.data = format!"Hello D %d."(i);
        writeln("Send: ", msg);
        pub.publish(msg);
    }

    Thread.sleep(1.seconds);

    shutdown();
}
