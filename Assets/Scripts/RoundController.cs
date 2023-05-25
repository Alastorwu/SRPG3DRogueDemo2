using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoundController : MonoBehaviour
{

    private RoundStatus RoundStatus = RoundStatus.unitControl;
    private bool AnimaPlay = false;


  


    public RoundStatus GetRoundStatus()
    {
        return RoundStatus;
    }

    void Awake()
    {
        /*GameObject mapManager = GameObject.Find("MapManager");
        MapCreater = mapManager.GetComponent<MapCreater>();*/
        InitRound();
    }

    public void InitRound()
    {
        GameObject prefab = Resources.Load<GameObject>("Prefab/Character/MaleCharacterPBR");
        Vector3 vector = new Vector3(1, 1, 1);
        RaycastHit hit;
        if (Physics.Raycast(vector, Vector3.down, out hit))
        {
            GameObject unit = Instantiate(
                  prefab,
                   hit.point,
                   Quaternion.identity);
            unit.transform.SetParent(GameObject.Find("SelfUnits").transform);
            CameraController cameraController = GameObject.Find("CameraController").GetComponent<CameraController>();
            cameraController.PutTarget(unit);
        }
    }

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public bool GetAnimaPlay()
    {
        return AnimaPlay;
    }

    public void SetAnimaPlay(bool animaPlay)
    {
        AnimaPlay = animaPlay;
    }
}
