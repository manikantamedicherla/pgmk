fun1() {
    echo "fun1 val $val"
    fun2
    echo "fun1 val $val"
}
fun2() {
    echo "fun2 val $val"
    fun3
    echo "fun2 val $val"
    
}
fun3() {
    echo "fun3 val $val"
    fun4
    echo "fun3 val $val"
    
}
fun4() {
    echo "fun4 val $val"
    fun5
    echo "fun4 val $val"
    
}
fun5() {
    echo "fun5 val $val"
    fun6
    echo "fun5 val $val"
    
}
fun6() {
    echo "fun6 val $val"
    fun7
    echo "fun6 val $val"
    
}
fun7() {
    echo "fun7 val $val"
    fun8
    echo "fun7 val $val"
    
}
fun8() {
    echo "fun8 val $val"
    fun9
    echo "fun8 val $val"
    
}
fun9() {
    echo "fun9 val $val"
    val="fun9"
    echo "fun9 val $val"
    
}
getcore() {
	core=$(grep -c ^processor /proc/cpuinfo)
}
getcore
echo "$core"
# test for variable scop
    # echo "initial val $val"
    # fun1
    # echo "final val $val"

# test for function declaration
testFunc
testFunc() {
    echo "No I dont working if I am declared below the invoke statement"
}
testFunc
