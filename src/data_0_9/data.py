# 读取Verilog代码文件
with open("zero.coe", "r") as file:
    verilog_code = file.readlines()

# 处理第三行到最后一行
for i in range(2, len(verilog_code)):
    line = verilog_code[i]
    # 寻找第一个数字的位置
    digit_index = next((idx for idx, char in enumerate(line) if char.isdigit()), None)
    if digit_index is not None:
        # 找到第一个逗号的位置
        comma_index = line.find(",", digit_index)
        if comma_index != -1:
            # 保留第一个数字，去除数字后的逗号
            modified_line = line[:comma_index] + line[comma_index+1:]
            verilog_code[i] = modified_line

# 将处理后的Verilog代码写回文件
with open("zero.mi", "w") as file:
    file.writelines(verilog_code)
