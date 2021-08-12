import sys,os,os.path,argparse


def check_existance(n_file, c_word, o_file='/opt/ranger/results/checks.txt'):
    # Open the file in read only mode
    with open(n_file, 'r') as read_obj:
        # Read all lines in the file one by one
        for line in read_obj:
            if c_word in line:
                output = str(n_file) + '\t True'
                break
            else:
                output = str(n_file) + '\t False'
        make_file_transfer(output, o_file=o_file)
 
def check_non_existance(n_file, c_word, o_file='/opt/ranger/results/checks.txt'):
    # Open the file in read only mode
    with open(n_file, 'r') as read_obj:
        # Read all lines in the file one by one
        for line in read_obj:
            if c_word in line:
                output = str(n_file) + '\t False'
                break
            else:
                output = str(n_file) + '\t True'
        make_file_transfer(output, o_file=o_file)

def make_file_transfer(output, o_file=r'/tmp/sample.txt'):
    print('writing output file at ' + o_file)

    if os.path.exists(o_file):
        append_write = 'a' # append if already exists
    else:
        append_write = 'w' # make a new file if not

    # Open a file with access and read mode 'a+'
    file_object = open(o_file, append_write)
    # Append 'hello' at the end of file
    file_object.write(output+'\n')
    # Close the file
    file_object.close()
    

def main():
    # Parse arguments from command line
    parser = argparse.ArgumentParser()

    # Set up required arguments this script
    parser.add_argument('function', type=str, choices=['check_non_existance', 'check_existance'], help='function to call')
    # Parse the given arguments
    #args = parser.parse_args()
    args, sub_args = parser.parse_known_args()
    
    # Get the function based on the command line argument and 
    # call it with the other two command line arguments as 
    # function arguments

    print(args.function)
    if args.function == 'check_existance':
        
        parser = argparse.ArgumentParser()
        parser.add_argument('n_file', help='source')
        parser.add_argument('c_word', type=str, help='word to match')
        parser.add_argument('-o', '--o_file', type=str, help='output file name', default='/opt/ranger/results/checks.txt')

        args = parser.parse_args(sub_args)
        check_existance(args.n_file, args.c_word, args.o_file)
        
    elif args.function == 'check_non_existance': 
        
        parser = argparse.ArgumentParser()
        parser.add_argument('n_file', help='source file')
        parser.add_argument('c_word', type=str, help='word to not match')
        parser.add_argument('-o', '--o_file', type=str, help='output file name', default='/opt/ranger/results/checks.txt')

        args = parser.parse_args(sub_args)
        check_non_existance(args.n_file, args.c_word, args.o_file)   

if __name__ == '__main__':
    main()
