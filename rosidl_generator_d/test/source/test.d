module test;

import std.stdio;
import rosidl_generator_d.msg;
import rosidl_generator_d.msg_c_interface;
import rcl_bind;
import std.string;
import std.conv : to;

@("msg") @("types")
unittest {
    const array = Arrays();
    const basic_types = BasicTypes();
    const bounded_sequences = BoundedSequences();
    const constants = Constants();
    const defaults = Defaults();
    const empty = Empty();
    const multi_nested = MultiNested();
    const nested = Nested();
    const strings = Strings();
    const unbounded_sequences = UnboundedSequences();
    const wstrings = WStrings();
}

@("msg") @("c_types")
unittest {
    // assert(is(BasicTypes.CMassageType == rosidl_generator_d__msg__BasicTypes));
    // assert(is(BasicTypes.CArrayMessageType == rosidl_generator_d__msg__BasicTypes__Sequence));
    // auto msg = BasicTypes.createCMessage();
    // assert(msg);
    // BasicTypes.destroyCMessage(msg);
    // assert(!msg);
    // auto msg_array = BasicTypes.createCMessage(10);
    // assert(msg_array.size == 10U);
    // assert(msg_array.capacity == 10U);
    // BasicTypes.destroyCMessage(msg_array);
    // assert(!msg_array);
    // assert(BasicTypes.getTypesupport());
}

void assignBasicTypes(T)(ref T basic, byte offset = 0) {
    basic.bool_value = offset % 2 == 0;
    basic.byte_value = cast(byte)(1 + offset);
    basic.char_value = cast(char)(2 + offset);
    basic.float32_value = 3.5f + offset;
    basic.float64_value = -4.5 + offset;
    basic.int8_value = cast(byte)(-5 + offset);
    basic.int16_value = cast(short)(-6 + offset);
    basic.uint16_value = cast(ushort)(7 + offset);
    basic.int32_value = -8 + offset;
    basic.uint32_value = 9 + offset;
    basic.int64_value = -10 + offset;
    basic.uint64_value = 11 + offset;
}

void checkBasicTypes(T)(in T basic, byte offset = 0) {
    assert(basic.bool_value == (offset % 2 == 0));
    assert(basic.byte_value == 1 + offset);
    assert(basic.char_value == 2 + offset);
    assert(basic.float32_value == 3.5f + offset);
    assert(basic.float64_value == -4.5 + offset);
    assert(basic.int8_value == -5 + offset);
    assert(basic.int16_value == -6 + offset);
    assert(basic.uint16_value == 7 + offset);
    assert(basic.int32_value == -8 + offset);
    assert(basic.uint32_value == 9 + offset);
    assert(basic.int64_value == -10 + offset);
    assert(basic.uint64_value == 11 + offset);
}

@("msg") @("convert_d_to_c")
unittest {
    const float_samples = [1.0f, 1.5f, 2.0f];
    const string_samples = ["hoge", "fuga", "piyo"];
    const wstring_samples = ["ほげ"w, "ふが"w, "ぴよ"w];

    // basic types
    auto basic = BasicTypes();
    auto c_basic = BasicTypes.createCMessage();

    assignBasicTypes(basic);

    BasicTypes.convert(basic, *c_basic);

    checkBasicTypes(*c_basic);

    BasicTypes.destroyCMessage(c_basic);

    // nested
    auto nested = Nested();
    auto c_nested = Nested.createCMessage();

    assignBasicTypes(nested.basic_types_value);

    Nested.convert(nested, *c_nested);

    checkBasicTypes(c_nested.basic_types_value);

    Nested.destroyCMessage(c_nested);

    // strings
    auto strings = Strings();
    auto c_strings = Strings.createCMessage();

    strings.string_value = string_samples[0];
    strings.bounded_string_value = string_samples[1];

    Strings.convert(strings, *c_strings);

    assert(strings.string_value == string_samples[0]);
    assert(strings.bounded_string_value == string_samples[1]);

    Strings.destroyCMessage(c_strings);

    // arrays
    auto arrays = Arrays();
    auto c_arrays = Arrays.createCMessage();

    arrays.float32_values = float_samples;
    arrays.string_values = string_samples;
    foreach (i; 0 .. 3) {
        assignBasicTypes(arrays.basic_types_values[i], cast(byte) i);
    }

    Arrays.convert(arrays, *c_arrays);

    foreach (i; 0 .. 3) {
        assert(c_arrays.float32_values[i] == float_samples[i]);
        assert(fromStringz(c_arrays.string_values[i].data) == string_samples[i]);
        checkBasicTypes(c_arrays.basic_types_values[i], cast(byte) i);
    }

    Arrays.destroyCMessage(c_arrays);

    // unbounded sequences
    auto unbounded = UnboundedSequences();
    auto c_unbounded = UnboundedSequences.createCMessage();

    unbounded.float32_values = new float[3];
    unbounded.string_values = new string[3];
    unbounded.basic_types_values = new BasicTypes[3];
    foreach (i; 0 .. 3) {
        unbounded.float32_values[i] = float_samples[i];
        unbounded.string_values[i] = string_samples[i];
        assignBasicTypes(unbounded.basic_types_values[i], cast(byte) i);
    }

    UnboundedSequences.convert(unbounded, *c_unbounded);

    assert(c_unbounded.bool_values.size == 0);
    assert(c_unbounded.float32_values.size == 3);
    assert(c_unbounded.string_values.size == 3);
    assert(c_unbounded.basic_types_values.size == 3);
    foreach (i; 0 .. 3) {
        assert(c_unbounded.float32_values.data[i] == float_samples[i]);
        assert(fromStringz(c_unbounded.string_values.data[i].data) == string_samples[i]);
        checkBasicTypes(c_unbounded.basic_types_values.data[i], cast(byte) i);
    }

    UnboundedSequences.destroyCMessage(c_unbounded);
}

@("msg") @("convert_c_to_d")
unittest {
    const float_samples = [1.0f, 1.5f, 2.0f];
    const string_samples = ["hoge", "fuga", "piyo"];
    const wstring_samples = ["ほげ"w, "ふが"w, "ぴよ"w];

    // basic types
    auto c_basic = BasicTypes.createCMessage();
    auto basic = BasicTypes();

    assignBasicTypes(*c_basic);

    BasicTypes.convert(*c_basic, basic);

    checkBasicTypes(basic);

    BasicTypes.destroyCMessage(c_basic);

    // nested
    auto c_nested = Nested.createCMessage();
    auto nested = Nested();

    assignBasicTypes(c_nested.basic_types_value);

    Nested.convert(*c_nested, nested);

    checkBasicTypes(nested.basic_types_value);

    Nested.destroyCMessage(c_nested);

    // strings
    auto c_strings = Strings.createCMessage();
    auto strings = Strings();

    rosidl_runtime_c__String__assign(&c_strings.string_value, toStringz(string_samples[0]));
    rosidl_runtime_c__String__assign(&c_strings.bounded_string_value, toStringz(string_samples[1]));

    Strings.convert(*c_strings, strings);

    assert(strings.string_value == string_samples[0]);
    assert(strings.bounded_string_value == string_samples[1]);

    Strings.destroyCMessage(c_strings);

    // arrays
    auto c_arrays = Arrays.createCMessage();
    auto arrays = Arrays();

    foreach (i; 0 .. 3) {
        c_arrays.float32_values[i] = float_samples[i];
        rosidl_runtime_c__String__assign(&c_arrays.string_values[i], toStringz(string_samples[i]));
        assignBasicTypes(c_arrays.basic_types_values[i], cast(byte) i);
    }

    Arrays.convert(*c_arrays, arrays);

    foreach (i; 0 .. 3) {
        assert(arrays.float32_values[i] == float_samples[i]);
        assert(arrays.string_values[i] == string_samples[i]);
        checkBasicTypes(arrays.basic_types_values[i], cast(byte) i);
    }

    Arrays.destroyCMessage(c_arrays);

    // unbounded sequences
    auto c_unbounded = UnboundedSequences.createCMessage();
    auto unbounded = UnboundedSequences();

    rosidl_runtime_c__float__Sequence__init(&c_unbounded.float32_values, 3);
    rosidl_runtime_c__String__Sequence__init(&c_unbounded.string_values, 3);
    rosidl_generator_d__msg__BasicTypes__Sequence__init(&c_unbounded.basic_types_values, 3);
    foreach (i; 0 .. 3) {
        c_unbounded.float32_values.data[i] = float_samples[i];
        rosidl_runtime_c__String__assign(&c_unbounded.string_values.data[i],
                toStringz(string_samples[i]));
        assignBasicTypes(c_unbounded.basic_types_values.data[i], cast(byte) i);
    }

    UnboundedSequences.convert(*c_unbounded, unbounded);

    assert(unbounded.bool_values.length == 0);
    assert(unbounded.float32_values.length == 3);
    assert(unbounded.string_values.length == 3);
    assert(unbounded.basic_types_values.length == 3);
    foreach (i; 0 .. 3) {
        assert(unbounded.float32_values[i] == float_samples[i]);
        assert(unbounded.string_values[i] == string_samples[i]);
        checkBasicTypes(unbounded.basic_types_values[i], cast(byte) i);
    }

    UnboundedSequences.destroyCMessage(c_unbounded);

}
