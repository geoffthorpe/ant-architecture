int main (void)
{
        int A, B, top, multiple;

        A = GetInteger ();
        B = GetInteger ();

        if ((A == 0) || (B <= 0)) {
                exit (0);
        }
        top = A * B;
        for (multiple = A; multiple <= top; multiple += A) {
                printf ("%d", multiple);
                printf ("%c", ' ');
        }
        printf ("%c", '\n');
        exit (0);
}
