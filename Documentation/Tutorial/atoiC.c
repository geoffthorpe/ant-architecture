int atoi (char *str)
{
        int sum = 0;
        int i;

        for (i = 0; str [i] != '\0'; i++) {
                sum *= 10;
                sum += (str [i] - '0');
        }
        return (sum);
}
