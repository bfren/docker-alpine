# Generate a random string of characters
export def string [
    length: int = 40    # The number of random characters to get
] {
    random chars -l $length
}