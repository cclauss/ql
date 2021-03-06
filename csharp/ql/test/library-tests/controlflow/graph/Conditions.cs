class Conditions
{
    void IncrOrDecr(bool inc, ref int x)
    {
        if (inc)
            x++;
        if (!inc)
            x--;
    }

    int M1(bool b)
    {
        var x = 0;
        if (b)
            x++;
        if (x > 0)
            if (!b)
                x--;
        return x;
    }

    int M2(bool b1, bool b2)
    {
        var x = 0;
        if (b1)
            if (b2)
                x++;
        if (b2)
            x++;
        return x;
    }

    int M3(bool b1)
    {
        var x = 0;
        var b2 = false;
        if (b1)
            b2 = b1;
        if (b2)
            x++;
        if (b2)
            x++;
        return x;
    }

    int M4(bool b, int x)
    {
        var y = 0;
        while (x-- > 0)
        {
            if (b)
                y++;
        }
        return y;
    }

    int M5(bool b, int x)
    {
        var y = 0;
        while (x-- > 0)
        {
            if (b)
                y++;
        }
        if (b)
            y++;
        return y;
    }

    int M6(string[] ss)
    {
        var b = ss.Length > 0;
        var x = 0;
        foreach (var _ in ss)
        {
            if (b)
                x++;
            if (x > 0)
                b = false;
        }
        if(b)
            x++;
        return x;
    }

    int M7(string[] ss)
    {
        var b = ss.Length > 0;
        var x = 0;
        foreach (var _ in ss)
        {
            if (b)
                x++;
            if (x > 0)
                b = false;
            if (b)
                x++;
        }
        return x;
    }

    string M8(bool b)
    {
        var x = b.ToString();
        if (b)
            x += "";
        if (x.Length > 0)
            if (!b)
                x += "";
        return x;
    }
}
