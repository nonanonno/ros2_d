module pub_sub;

import std.stdio;
import rcld;
import rcld_test_msgs.msg;
import std.process : executeShell;
import std.algorithm : canFind;
import std.array : split;

import std.concurrency;
import core.thread;
import core.stdc.stdio;

unittest {

    init();
    auto node = new Node("test", "");
    auto pub = new Publisher!TestA(node, "test_a");
    auto topics = executeShell("ros2 topic list");

    auto msg = TestA();
    msg.time = 10;
    pub.publish(msg);

    shutdown();

    assert(topics.output.split('\n').canFind("/test_a"));
}

void listener() {
    try {
        auto node_sub = new Node("test_sub", "");
        auto sub = new Subscription!TestA(node_sub, "/test_b");
        sub.callback_ = delegate(in TestA msg) { assert(msg.time == 10); };
        auto exec = new Executor();
        exec.addNode(node_sub);
        exec.spinOnce();
    }
    catch (Exception e) {
        writeln(e);
        assert(false);
    }
    finally {
        send(ownerTid, true);
    }
}

void talker() {

    auto node_pub = new Node("test_pub", "");
    auto pub = new Publisher!TestA(node_pub, "/test_b");

    Thread.sleep(1.seconds);

    auto msg = TestA();
    msg.time = 10;
    pub.publish(msg);
}

unittest {

    init();

    spawn(&listener);
    talker();
    assert(receiveOnly!(bool));
    shutdown();

}
