import std.stdio;
import rcld;
import std_msgs.msg : String;

void main() {
    init();

    auto node = new Node("listener", "");
    auto sub = new Subscription!String(node, "/chatter");
    sub.callback_ = delegate(in String msg) { writeln("Receive: ", msg); };

    auto executor = new Executor();
    executor.addNode(node);

    foreach (_; 0 .. 10) {
        executor.spinOnce();
    }

    shutdown();
}
