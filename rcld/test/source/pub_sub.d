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

    auto cxt = new Context();
    auto node = new Node("test_pub_sub_pub", "test_rcld", cxt);
    auto pub = new Publisher!TestA(node, "/test_rcld/pub_sub_a");
    auto topics = executeShell("ros2 topic list");

    auto msg = TestA();
    msg.time = 10;
    pub.publish(msg);

    cxt.shutdown();

    assert(topics.output.split('\n').canFind("/test_rcld/pub_sub_a"));
}

unittest {

    auto cxt = new Context();

    auto exec = new Executor(cxt);

    auto node_pub = new Node("pub_sub_talker", "test_rcld", cxt);
    auto pub = new Publisher!TestA(node_pub, "/test_rcld/pub_sub_b");

    auto node_sub = new Node("pub_sub_listener", "test_rcld", cxt);
    auto sub = new Subscription!TestA(node_sub, "/test_rcld/pub_sub_b");
    sub.callback_ = delegate(in TestA msg) { assert(msg.time == 10); };

    exec.addNode(node_sub);

    Thread.sleep(1.seconds);

    auto msg = TestA();
    msg.time = 10;
    pub.publish(msg);

    exec.spinOnce();

    cxt.shutdown();

}
