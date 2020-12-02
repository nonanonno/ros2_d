@{
from rosidl_generator_d import  solve_depends, \
                                idl_type_to_d, \
                                assign_text_d_to_c, \
                                assign_text_c_to_d, \
                                array_init_text_d_to_c_with_semicolon, \
                                array_init_text_c_to_d_with_semicolon
                                
from rosidl_generator_c import  idl_structure_type_to_c_typename, \
                                idl_structure_type_sequence_to_c_typename
from rosidl_parser.definition import AbstractNestedType

this_module = (package_name, 'msg')
}@
@[for dep in solve_depends(contents, this_module)]@
import @('.'.join(dep));
@[end for]@

@[for content in contents]@
@{
namespaced_type = content.structure.namespaced_type
type_name = namespaced_type.name
c_type_name = idl_structure_type_to_c_typename(namespaced_type)
c_array_type_name = idl_structure_type_sequence_to_c_typename(namespaced_type)
typesupport_function = "rosidl_typesupport_c__get_message_type_support_handle__" + c_type_name
}@
struct @(type_name) {
    alias This = typeof(this);
    alias CMessageType = CMessageOf!This;
    alias CArrayMessageType = CArrayMessageOf!This;

@[  for member in content.structure.members ]@
    @(idl_type_to_d(member.type)) @(member.name);
@[  end for]@
    
    static const(rosidl_message_type_support_t)* getTypesupport() @@nogc nothrow {
        return typesupportOf!This;
    }

    static CMessageType* createCMessage() @@nogc nothrow {
        return create!This();
    }

    static void destroyCMessage(ref CMessageType * msg) @@nogc nothrow {
        destroy!This(msg);
    }

    static void convert(in This src, ref CMessageType dst) {
        @('.'.join(this_module)).convert(src, dst);
    }

    static void convert(in CMessageType src, ref This dst) {
        @('.'.join(this_module)).convert(src, dst);
    }

}

const(rosidl_message_type_support_t)* typesupportOf(T)() @@nogc nothrow
    if (is(T == @(type_name))) {
    return @(typesupport_function)();
}

template CMessageOf(T) if(is(T == @(type_name))) {
    alias CMessageOf = @(c_type_name);
}

template CArrayMessageOf(T) if(is(T == @(type_name))) {
    alias CArrayMessageOf = @(c_array_type_name);
}

CMessageOf!T * create(T)() @@nogc nothrow 
    if(is(T == @(type_name))) {
    return @(c_type_name)__create();
}

void destroy(T)(ref CMessageOf!T * msg) @@nogc nothrow 
    if(is(T == @(type_name))) {
    @(c_type_name)__destroy(msg);
    msg = null;
}

CArrayMessageOf!T *create(T)(size_t size) @@nogc nothrow
    if(is(T == @(type_name))) {
    return @(c_array_type_name)__create(size);
}

void destroy(T)(ref CArrayMessageOf!T * msg) @@nogc nothrow
    if(is(T == @(type_name))) {
    @(c_array_type_name)__destroy(msg);
    msg = null;
}

void convert(T, U)(in T src, ref U dst)
    if(is(T == @(type_name)) && is(U == CMessageOf!T)) {
@[  for member in content.structure.members]@
@[    if isinstance(member.type, AbstractNestedType)]@
    @(array_init_text_d_to_c_with_semicolon(member, 'src.%s', 'dst.%s'))
    foreach(i; 0..src.@(member.name).length) {
        @(assign_text_d_to_c(member, 'src.%s[i]', 'dst.%s[i]'));
    }
@[    else]@
    @(assign_text_d_to_c(member, 'src.%s', 'dst.%s'));
@[    end if]@
@[  end for]@
}

void convert(T, U)(in U src, ref T dst)
    if(is(T == @(type_name)) && is(U == CMessageOf!T)) {
@[  for member in content.structure.members]@
@[    if isinstance(member.type, AbstractNestedType)]@
    @(array_init_text_c_to_d_with_semicolon(member, 'src.%s', 'dst.%s'))
    foreach(i; 0..dst.@(member.name).length) {
        @(assign_text_c_to_d(member, 'src.%s[i]', 'dst.%s[i]'));
    }
@[    else]@
    @(assign_text_c_to_d(member, 'src.%s', 'dst.%s'));
@[    end if]@
@[  end for]@
}

@[end for]@