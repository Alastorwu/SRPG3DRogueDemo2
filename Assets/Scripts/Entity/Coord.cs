using UnityEngine;

public class Coord
{

    public int CoordX { get; set; }
    public int CoordZ { get; set; }
    public Quaternion Rotation { get; set; }
    //public GameObject SourceGameObject { get; set; }
    public GameObject ReplaceGameObject { get; set; }

    public Coord( GameObject replaceGameObject, int x, int z, Quaternion rotation)
    {
        //this.SourceGameObject = sourceGameObject;
        this.ReplaceGameObject = replaceGameObject;
        this.CoordX = x;
        this.CoordZ = z;
        this.Rotation = rotation;
    }
}
