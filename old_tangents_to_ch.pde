color red = color(214, 58, 55);
color green = color(58, 242, 110);
color blue = color(72, 121, 159);

Polygon poly;
Point q;

void setup() {
    area = document.getElementById("sketch");
    smooth();
    noLoop();
    size(parseInt(area.style.width), parseInt(area.style.height));
    poly = new Polygon();
    background(45, 51, 58);
}

void draw() {
    area = document.getElementById("sketch");
    noStroke();
    fill(45, 51, 58);
    rect(0, 0, parseInt(area.style.width), parseInt(area.style.height));
    poly = convex_hull(poly.getPoints());
    poly.draw();
    if (q != null) {
        if (is_in_ch(poly.getPoints(), q)) {
            q.col = green;
        } else {
            q.col = red;
            Point up = upper_tangent(poly.getPoints(), q);
            Point lo = lower_tangent(poly.getPoints(), q);
            Segment up_tang = new Segment(q, up);
            Segment lo_tang = new Segment(q, lo);
            up_tang.col = red;
            lo_tang.col = red;
            up_tang.draw();
            lo_tang.draw();
        }
        q.draw();
    }
}

void mouseClicked() {
    if (mouseButton == LEFT)
        poly.add(new Point(mouseX, mouseY));
    else if (mouseButton == RIGHT)
        q = new Point(mouseX, mouseY);
    redraw();
}

class Point {
    int x, y;
    color col = blue;

    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    bool is_equal(Point a) {
        return (this.x == a.x && this.y == a.y);
    }

    void draw() {
        pushStyle();
        fill(this.col);
        strokeWeight(0.5);
        ellipse(x, y, 7, 7);
        popStyle();
    }
};

class Segment {
    Point a, b;
    color col = blue;

    Segment(Point a, Point b) {
        this.a = a;
        this.b = b;
    }

    void draw() {
        pushStyle();
        stroke(this.col);
        strokeWeight(2);
        line(this.a.x, this.a.y, this.b.x, this.b.y);
        this.a.col = this.col;
        this.b.col = this.col;
        a.draw();
        b.draw();
        popStyle();
    }
};

class SetOfPoints {
    ArrayList points;
    color col = blue;

    SetOfPoints() {
        this.points = new ArrayList();
    }

    SetOfPoints(ArrayList<Point> p) {
        this.points = p;
    }

    ArrayList getPoints() {
        return this.points;
    }

    ArrayList subset(int index, int max_size) {
        ArrayList p = new ArrayList();
        int n = this.points.size();
        int subset_nbr = ceil(n/max_size);

        for (int i = index*max_size; (i < n) && (p.size() < max_size); ++i) {
            p.add(this.points.get(i));
        }

        return p;
    }

    void add(Point &p) {
        this.points.add(p);
    }

    Point remove(int i) {
        return this.points.remove(i);
    }
    
    int size() {
        return this.points.size();
    }

    Point get(int i) {
        return this.points.get(i);
    }

    Point last() {
        if (this.points.size() > 0)
            return this.points.get(this.points.size()-1);
        else    
            return null;
    }

    Point x_min() {
        Point p = this.points.get(0);
        for (int i = 1; i < this.points.size(); ++i) {
            if (this.points.get(i).x < p.x) {
                p = this.points.get(i);
            } else if (this.points.get(i).x == p.x && this.points.get(i).y < p.y) {
                p = this.points.get(i);
            }
        }
        return p;
    }

    Point x_max() {
        Point p = this.points.get(0);
        for (int i = 1; i < this.points.size(); ++i) {
            if (this.points.get(i).x > p.x) {
                p = this.points.get(i);
            } else if (this.points.get(i).x == p.x && this.points.get(i).y > p.y) {
                p = this.points.get(i);
            }
        }
        return p;
    }

    Point y_min() {
        Point p = this.points.get(0);
        for (int i = 1; i < this.points.size(); ++i) {
            if (this.points.get(i).y < p.y) {
                p = this.points.get(i);
            } else if (this.points.get(i).y == p.y && this.points.get(i).x < p.x) {
                p = this.points.get(i);
            }
        }
        return p;
    }

    Point y_max() {
        Point p = this.points.get(0);
        for (int i = 1; i < this.points.size(); ++i) {
            if (this.points.get(i).y > p.y) {
                p = this.points.get(i);
            } else if (this.points.get(i).y == p.y && this.points.get(i).x > p.x) {
                p = this.points.get(i);
            }
        }
        return p;
    }

    void ccw_angle_sort(int i) {
        ArrayList sorted = new ArrayList();
        Point pivot = this.points.remove(i);
        sorted.add(pivot);

        while (this.points.size() > 0) {
            Point p = this.points.get(0);
            for (int i = 1; i < this.points.size(); ++i) {
                float deltaX_p = (p.x - pivot.x);
                float deltaY_p = (p.y - pivot.y);
                float deltaX_i = (this.points.get(i).x - pivot.x);
                float deltaY_i = (this.points.get(i).y - pivot.y);

                if (atan2(deltaY_i, deltaX_i) < atan2(deltaY_p, deltaX_p)) {
                    p = this.points.get(i);
                } else if (atan2(deltaY_i, deltaX_i) == atan2(deltaY_p, deltaX_p) && this.points.get(i).x > p.x) {
                    p = this.points.get(i);
                }
            }
            sorted.add(p);
            this.points.remove(p);
        }
        this.points = sorted;
    }

    void draw() {
        pushStyle();
        beginShape();
        for (int p = 0; p < this.points.size(); p++) {
            Point pt = (Point) this.points.get(p);
            pt.col = this.col;
            pt.draw();
        }
        endShape(CLOSE);
        popStyle();
    }
};

class Polygon extends SetOfPoints {
    Polygon(ArrayList<Point> p) {
        this.points = p;
    }
    
    void draw() {
        pushStyle();
        strokeWeight(3);
        stroke(this.col);
        noFill();
        beginShape();
        for (int p = 0; p < this.points.size(); p++) {
            Point pt = (Point) this.points.get(p);
            vertex(pt.x, pt.y);
            pt.col = this.col;
            pt.draw();
        }
        endShape(CLOSE);
        popStyle();
    }
};

bool is_cw(Point a, Point b, Point c) {
    return (b.y - a.y)*(c.x - a.x) < (b.x - a.x)*(c.y - a.y);
}

bool is_ccw(Point a, Point b, Point c) {
    return (b.y - a.y)*(c.x - a.x) > (b.x - a.x)*(c.y - a.y);
}

bool is_in_triangle(Point a, Point b, Point c, Point p) {
    bool sens = is_cw(a, b, c);
    Point[] tri = {a, b, c};
    for (int i = 0; i < 3; i++) {
        if (sens != is_cw(tri[i], tri[(i+1)%3], p))
            return false;
    }
    return true;
}

Point min_p(ArrayList<Point> points) {
    Point p = points.get(0);
    for (int i = 1; i < points.size(); ++i) {
        if (points.get(i).x < p.x) {
            p = points.get(i);
        } else if (points.get(i).x == p.x && points.get(i).y < p.y) {
            p = points.get(i);
        }
    }
    return p;
}

Point max_p(ArrayList<Point> points) {
    Point p = points.get(0);
    for (int i = 1; i < points.size(); ++i) {
        if (points.get(i).x > p.x) {
            p = points.get(i);
        } else if (points.get(i).x == p.x && points.get(i).y > p.y) {
            p = points.get(i);
        }
    }
    return p;
}

Polygon convex_hull_jm(ArrayList<Point> points) {
    if (points.size() <= 3)
        return new Polygon(points);
    
    ArrayList p = new ArrayList(); 
    Point start_point = min_p(points);
    Point end_point;
    
    int i = 0;
    do {
        p.add(start_point);
        end_point = points.get(0);
        for (int j = 1; j < points.size(); ++j) {
            if ((end_point == start_point) || is_cw(p.get(i), end_point, points.get(j)))
                end_point = points.get(j);
        }
        ++i;
        start_point = end_point;
    } while (end_point != p.get(0));

    return new Polygon(p);
}

Polygon convex_hull_gs(ArrayList<Point> points) {
    if (points.size() <= 3)
        return new Polygon(points);
    
    SetOfPoints p = new SetOfPoints(points); 
    Point start_point = p.y_min(points);
    p.ccw_angle_sort(p.points.indexOf(start_point));
    p.add(start_point);
    ArrayList pile = new ArrayList();
    pile.add(p.get(0));
    pile.add(p.get(1));

    for (int i = 2; i < p.size(); ++i) {
        while ( pile.size() >= 2 && !is_cw(pile.get(pile.size()-2), pile.get(pile.size()-1), p.get(i)) )
            pile.remove(pile.size()-1);
        pile.add(p.get(i));
    }

    return new Polygon(pile);
}

Polygon convex_hull_chan(ArrayList<Point> points, int m, int h) {
    int n = points.size();
    if (n <= 3)
        return new Polygon(points);

    Polygon ch = new Polygon();
    SetOfPoints p = new SetOfPoints(points);
    ArrayList sub_p_set = new ArrayList();

    for (int j = 0; j < ceil(n/m); ++j) {
        sub_p_set.add(p.subset(j, ceil(n/m)));
    }

    ch.add(new Point(0, 0));
    ch.add(p.x_max());

    for (int k = 0; k < h; ++k) {
        SetOfPoints q_set = new SetOfPoints();
        for (int i = 0; i < ceil(n/m); ++i) {
            q_set.add(lower_tangent(sub_p_set.get(i), ch.last()));
        }
        Point new_p = q_set.remove(0);
        while (q_set.size() > 0) {
            Point q = q_set.remove(0);
            if(is_ccw(ch.last(), new_p, q))
                new_p = q;
        }
        ch.add(new_p);
        if (new_p.is_equal(ch.get(1))) {
            ch.remove(0);
            return ch;
        }
    }
    return null;

}

Polygon convex_hull(ArrayList<Point> points) {
    int n = points.size();

    if (n <= 3)
        return new Polygon(points);

    Polygon l;
    for (int m = 2, i = 0; m <= n; ++i, m = pow(2, pow(2, i))) {
        l = convex_hull_chan(points, min(m, n), min(m, n));
        if (l != null)
            return l;
    }
}

Point is_in_ch(ArrayList<Point> points, Point q) {
    Polygon ch = convex_hull_jm(points);
    ArrayList<Point> p = ch.getPoints();
    int n = p.size();
    int lo = 1;
    int hi = n-1;

    if (is_cw(p.get(0), p.get(1), q) || is_ccw(p.get(0), p.get(n-1), q))
        return false;

    while (lo < hi-1) {
        int m = floor((lo+hi)/2);

        if (is_cw(p.get(0), p.get(m), q))
            hi = m;
        else
            lo = m;
    }

    if (is_ccw(p.get(lo), p.get(hi), q))
        return true;
    else
        return false;
}

/*
   http://geomalgorithms.com/a15-_tangents.html#tangent_PointPolyC()
 */

Point upper_tangent(ArrayList<Point> points, Point q) {
    Polygon ch = convex_hull_jm(points);
    ArrayList<Point> p = ch.getPoints();
    int n = p.size();
    int a = 0;
    int b = n;
    
    if (n == 1)
        return p.get(0);
    if (n == 2) {
        if(is_cw(q, p.get(0), p.get(1)))
            return p.get(0);
        else
            return p.get(1);
    }

    if (is_cw(q, p.get(0), p.get(1)) && !is_ccw(q, p.get(0), p.get(n-1)))
        return p.get(0);

    p.add(p.get(0));
    for (;;;) {
        int c = floor((a+b)/2);

        if (is_cw(q, p.get(c), p.get(c+1)) && !is_ccw(q, p.get(c), p.get(c-1))) {
            p.remove(n);
            return p.get(c);
        }

        if (is_ccw(q, p.get(a), p.get(a+1))) {
            if (is_cw(q , p.get(c), p.get(c+1)))
                b = c;
            else {
                if (is_ccw(q, p.get(c), p.get(a)))
                    b = c;
                else
                    a = c;
            }
        }
        else {
            if (!is_cw(q, p.get(c), p.get(c+1)))
                a = c;
            else {
                if (is_cw(q, p.get(c), p.get(a)))
                    b = c;
                else
                    a = c;
            }
        }
    }
}

Point lower_tangent(ArrayList<Point> points, Point q) {
    Polygon ch = convex_hull_jm(points);
    ArrayList<Point> p = ch.getPoints();
    int n = p.size();
    int a = 0;
    int b = n;

    if (n == 1)
        return p.get(0);
    if (n == 2) {
        if(is_ccw(q, p.get(0), p.get(1)))
            return p.get(0);
        else
            return p.get(1);
    }

    if (is_ccw(q, p.get(0), p.get(n-1)) && !is_cw(q, p.get(0), p.get(1)))
        return p.get(0);

    p.add(p.get(0));
    for (;;;) {
        int c = floor((a+b)/2);

        if (is_ccw(q, p.get(c), p.get(c-1)) && !is_cw(q, p.get(c), p.get(c+1))) {
            p.remove(n);
            return p.get(c);
        }

        if (is_cw(q, p.get(a), p.get(a+1))) {
            if (!is_cw(q , p.get(c), p.get(c+1)))
                b = c;
            else {
                if (is_cw(q, p.get(c), p.get(a)))
                    b = c;
                else
                    a = c;
            }
        }
        else {
            if (is_cw(q, p.get(c), p.get(c+1)))
                a = c;
            else {
                if (is_ccw(q, p.get(c), p.get(a)))
                    b = c;
                else
                    a = c;
            }
        }
    }
}