using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class UnitController : MonoBehaviour
{

    public GameObject ChooseObject;
    private RoundController RoundController;
    private bool Moving = false;
    private Vector3 TargetPos;
    private float MoveSpeed = 2f;


    // Start is called before the first frame update
    void Start()
    {
        RoundController = GameObject.Find("RoundController").GetComponent<RoundController>();
    }
    public void UnitMove(Vector3 targetPos)
    {
        TargetPos = targetPos;
        RoundController.SetAnimaPlay(true);
        Moving = true;
        ChooseObject.GetComponent<Animator>().SetBool("Move", Moving);
    }

    // Update is called once per frame
    void Update()
    {
        if (Moving && ChooseObject!=null) 
        {
            Vector3 originPos = ChooseObject.transform.position;
            Vector3 direction = TargetPos - originPos;
            
            if (direction.magnitude > 0.2f)
            {
                ChooseObject.transform.Translate(direction.normalized * MoveSpeed * Time.deltaTime);
            }
            else if (direction.magnitude > 0.1f)
            {
                ChooseObject.transform.Translate(direction.normalized * 0.5f * Time.deltaTime);
            }
            else
            {
                ChooseObject.transform.position = TargetPos;
                Moving = false;
                RoundController.SetAnimaPlay(false);
                ChooseObject.GetComponent<Animator>().SetBool("Move", Moving);
            }

        }
    }
}
