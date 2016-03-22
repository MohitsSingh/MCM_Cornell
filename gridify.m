function pts = gridify(polygons, hull, d, bounds, inner, verbose)
    xmin = bounds(1);
    xmax = bounds(2);
    ymin = bounds(3);
    ymax = bounds(4);
    xd = round((xmax-xmin)/d);
    yd = round((ymax-ymin)/d);
    pts = zeros(xd,yd);
    bsq = [xmin,ymin;xmin,ymin;xmin,ymin;xmin,ymin];
    
    for i=1:xd
        if (~inner && verbose)
            i
        end
        for j=1:yd
            sq = bsq + d*[i-1,j-1;i,j-1;i,j;i-1,j];
            s1 = sq(1,:);
            s2 = sq(2,:);
            s3 = sq(3,:);
            s4 = sq(4,:);
            s5 = mean(sq);
            s = {s1 s2 s3 s4 s5};
            done = 0;
            if (~isRectInsidePoly(hull{1}, hull{2}, s))
                done = 1;
            end
            if (i > 1 && ~done)
                k = pts(i-1,j);
                if (k ~= 0 && isRectInsidePoly(polygons{1,k}, polygons{2,k}, s) > 2)
                    pts(i,j) = k;
                    done = 1;
                end
            end
            if (j > 1 && ~done)
                k = pts(i,j-1);
                if (k ~= 0 && isRectInsidePoly(polygons{1,k}, polygons{2,k}, s) > 2)
                    pts(i,j) = k;
                    done = 1;
                end
            end
            if (~done)
                for k=1:size(polygons,2)
                    num = isRectInsidePoly(polygons{1,k}, polygons{2,k}, s);
                    if (num > 2)
                        pts(i,j) = k;
                        break
                    end
    %                 a1 = isPointInsidePoly(polygons{1,k}, polygons{2,k}, s1);
    %                 a2 = isPointInsidePoly(polygons{1,k}, polygons{2,k}, s2);
    %                 a3 = isPointInsidePoly(polygons{1,k}, polygons{2,k}, s3);
    %                 a4 = isPointInsidePoly(polygons{1,k}, polygons{2,k}, s4);
    %                 a5 = isPointInsidePoly(polygons{1,k}, polygons{2,k}, s5);
    %                 if (a1 + a2 + a3 + a4 + a5 > 2)
    %                     pts(i,j) = k;
    %                     break
    %                 end
                end
            end
        end
    end
    if (~inner)
        bighull = [-10000 -10000; 10000 -10000; 10000 10000; -10000 10000; -10000 -10000]; % big triangle 
        for i=1:xd
            for j=1:yd
                if (pts(i,j) == 0)
                    if (j < yd && pts(i,j+1)) || (i < xd && pts(i+1,j)) || (j > 1 && pts(i,j-1)) || (i > 1 && pts(i-1,j))
                        sq = bsq + d*[i-1,j-1;i,j-1;i,j;i-1,j];
                        bd = [sq(1,1) sq(3,1), sq(1,2) sq(3,2)];
                        pl = cell(2,4);
                        count = 1;
                        polyindices = [];
                        if (j < yd && pts(i,j+1) ~= 0)
                            pl{1,1} = polygons{1,pts(i,j+1)};
                            pl{2,1} = polygons{2,pts(i,j+1)};
                            count = count + 1;
                            polyindices = [polyindices pts(i,j+1)];
                        end
                        if (i < xd && pts(i+1,j) ~= 0)
                            pl{1,count} = polygons{1,pts(i+1,j)};
                            pl{2,count} = polygons{2,pts(i+1,j)};
                            count = count + 1;
                            polyindices = [polyindices pts(i+1,j)];
                        end
                        if (j > 1 && pts(i,j-1) ~= 0)
                            pl{1,count} = polygons{1,pts(i,j-1)};
                            pl{2,count} = polygons{2,pts(i,j-1)};
                            count = count + 1;
                            polyindices = [polyindices pts(i,j-1)];
                        end
                        if (i > 1 && pts(i-1,j) ~= 0)
                            pl{1,count} = polygons{1,pts(i-1,j)};
                            pl{2,count} = polygons{2,pts(i-1,j)};
                            polyindices = [polyindices pts(i-1,j)];
                        end
                        Q=gridify(pl,{bighull(:,1),bighull(:,2)},d/3,bd,1,false);
                        mostoften = mode(reshape(Q,9,1));
                        if (mostoften ~= 0)
                            pts(i,j) = polyindices(mostoften);
                        end
                    end
                end
            end
        end
    end
    for i=1:xd
        for j=1:yd
            if (pts(i,j) == 0)
                if (j < yd && pts(i,j+1)) && (i < xd && pts(i+1,j)) && (j > 1 && pts(i,j-1)) && (i > 1 && pts(i-1,j))
                    pts(i,j) = mode([pts(i,j+1) pts(i+1,j+1) pts(i,j-1) pts(i-1,j)]);
                end
            end
        end
    end
end
